#!/usr/bin/env ruby -w

require 'optparse'    # OptionParser
require 'ostruct'

class ApacheLogProcessor
  VERSION = '1.0.0'

  def initialize(options, log_file)
    @threads = options.threads
    @log_file = log_file
  end

  def self.run(args)
    options = AlpParser.parse(args)
    apl = ApacheLogProcessor.new(options, ARGV[0])
#    apl.process
  end


end

class AlpParser
  def self.parse(args)
    options = OpenStruct.new
    options.threads = 100

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: apache_log_processor [options] <log_file>"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-t", "--threads [THREADS]", Integer, "Number of threads to spawn (default=100).") do |threads|
        options.threads = threads
      end
    end

    opts.parse!(args)
    options
  end
end

ApacheLogProcessor.run(ARGV) if $0 == __FILE__
