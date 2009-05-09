require 'optparse'    # OptionParser
require 'ostruct'
require 'apache_log_processor'

class ApacheLogProcessorRunnable
  def initialize
    @alp = ApacheLogProcessor.new
  end

  def self.parse
    options = OpenStruct.new
    options.threads = 100

    # define the parser
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: apache_log_processor [options] <log_file>"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-t", "--threads [THREADS]", Integer, "Number of threads to spawn (default=100).") do |threads|
        options.threads = threads
      end
    end

    # do the parsing
    opts.parse ARGV
    options


  end

  def run
    parse
  end

end
