#!/usr/bin/env ruby -w

# Peter Held
# Week 4 homework

require 'optparse'    # OptionParser
require 'ostruct'
require 'resolv'      # DNS resolver
require 'fileutils'
require 'thread'
require 'yaml'
require 'time'

class ApacheLogProcessor
  VERSION = '1.0.0'
  CACHE_AGE_LIMIT = 60 * 60 * 24    # 1 day, in seconds
  IP_REGEX = /(\d+)\.(\d+)\.(\d+)\.(\d+)/

  attr_accessor :threads, :cache_path, :log_path, :dns_cache, :log_lines, :parsed_lines

  def initialize(options, log_path)
    @threads = options.threads          # specifies the number of threads to spawn
    @cache_path = options.cache_file    # the path to the cache file
    @log_path = log_path                # the path to the log file to read/write
    @dns_cache = {}                     # for storing the looked-up values
    @cache_mutex = Mutex.new            # for synchronizing access to the DNS cache
    @log_queue = Queue.new              # for queueing the processing of each line
    @log_lines = []                     # for storing the original log lines
    @parsed_lines = []                  # for storing the resulting modified lines
  end

  def self.run(args)
    options = AlpParser.parse(args)
    apl = ApacheLogProcessor.new(options, ARGV[0])

    # read the cache from disk
    apl.read_cache

  end

  def read_log_file
    file = File.new(@log_path)

    file.each do |line|
      @log_lines << { :number => (file.lineno - 1), :line => line }
    end
  end

  def lookup_ip_address(ip_address)
    name = ip_address

    # attempt to find the ip address in the cache
    cache_hit = @dns_cache[ip_address]

    unless cache_hit
      name = lookup_ip_address_network(ip_address)
    else
      if cache_item_too_old(cache_hit)
        name = lookup_ip_address_network(ip_address)
      else
        name = cache_hit["name"]
      end
    end

    name

  end

  def lookup_ip_address_network(ip_address)
    name = ip_address   # in case we have a problem looking it up, we'll just return the original IP address

    begin
      name = Resolv.getname(ip_address)

      # update the cache
      @dns_cache[ip_address]["name"] = name
      @dns_cache[ip_address]["time"] = Time.now.to_s
    rescue Exception => e 
      print "Exception occurred while looking up an IP \"#{ip_address}\": #{e.message}\n"
    end

    name
  end

  def cache_item_too_old(cache_item)
    ( ( Time.now - CACHE_AGE_LIMIT ) <=> Time.parse(cache_item["time"]) ) == 1
  end 

  def read_cache
    if File.exists?(@cache_path)
      @dns_cache = YAML::load(File.read(@cache_path))
    else
      puts "Could not find the cache file at #{@cache_path}"
    end
  end

  def get_ip(log_line)
    log_line.match(IP_REGEX)[0]
  end

  def process_line(log_line)
    processed_line = log_line

    ip_address = get_ip(log_line)

    if ip_address
      name = lookup_ip_address(ip_address)

      processed_line = log_line.gsub(IP_REGEX, name)
    end

    processed_line
  end

  def process_lines
    workers = []

    (0..@threads).each do |x|
      workers << Thread.new do
        until(@log_lines.empty?)
          line = @log_lines.pop
          @parsed_lines[line[:number]] = process_line(line)
        end
      end
    end

    workers.each do |worker|
      worker.join
    end

  end 
  
end

class AlpParser
  def self.parse(args)
    options = OpenStruct.new
    options.threads = 100
    options.cache_file = './dns_cache'

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: apache_log_processor [options] <log_file>"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-t", "--threads [THREADS]", Integer, "Number of threads to spawn (default=100).") do |threads|
        options.threads = threads
      end

      opts.on("-c", "--cache_file [CACHE_FILE]", String, "Path to the cache file to use (default = \"./dns_cache\"") do |cache_file|
        option.cache_file = cache_file
      end
    end

    opts.parse!(args)
    options
  end
end

ApacheLogProcessor.run(ARGV) if $0 == __FILE__
