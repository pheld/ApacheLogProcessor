# Peter Held
# Week 4 homework

require 'test/unit'
require 'ostruct'
require 'apache_log_processor'
require 'resolv'

class TestApacheLogProcessor < Test::Unit::TestCase

  def setup
    options = OpenStruct.new
    options.threads = 100
    options.cache_file = './test/test_cache'
    @apl = ApacheLogProcessor.new(options, './test/test_log')
  end

  def test_looks_up_dns_name_with_network
    ip = "127.0.0.1"

    name = @apl.lookup_ip_address_network(ip)

    assert_equal("localhost", name)
  end

  def test_dns_network_lookup_fails_gracefully
    ip = "999.999.999.x"

    name = @apl.lookup_ip_address_network(ip)

    # the name should match the IP, because it's invalid and I just return the input if it fails
    assert_equal(ip, name)
  end

  def test_read_cache_file
    assert_equal(0, @apl.dns_cache.length)

    @apl.read_cache

    assert_equal(2, @apl.dns_cache.length)

    assert_equal("localhost", @apl.dns_cache["127.0.0.1"]["name"])
    assert_equal("www.yahoo.com", @apl.dns_cache["209.131.36.158"]["name"])
  end 

  def test_cache_hit_too_old_true
    @apl.read_cache

    one_day_one_minute_ago = Time.now - 86460

    @apl.dns_cache["209.131.36.158"]["time"] = one_day_one_minute_ago.to_s

    assert_equal(true, @apl.cache_item_too_old(@apl.dns_cache["209.131.36.158"]))
  end

  def test_cache_hit_too_old_false
    @apl.read_cache

    one_minute_less_than_a_day_ago = Time.now - 86340

    @apl.dns_cache["209.131.36.158"]["time"] = one_minute_less_than_a_day_ago.to_s

    assert(!@apl.cache_item_too_old(@apl.dns_cache["209.131.36.158"]))
  end

  def test_cache_hit_within_age_limit
    @apl.read_cache

    assert_equal(2, @apl.dns_cache.length)

    one_minute_less_than_a_day_ago = Time.now - 86340
    @apl.dns_cache["209.131.36.158"]["time"] = one_minute_less_than_a_day_ago.to_s

    name = @apl.lookup_ip_address("209.131.36.158")

    assert_equal("www.yahoo.com", @apl.dns_cache["209.131.36.158"]["name"])
    assert_equal(2, @apl.dns_cache.length)
    assert_equal(one_minute_less_than_a_day_ago.to_s, @apl.dns_cache["209.131.36.158"]["time"])
  end

  def test_cache_hit_beyond_age_limit
    @apl.read_cache

    assert_equal(2, @apl.dns_cache.length)

    one_minute_less_than_a_day_ago = Time.now - 200000
    @apl.dns_cache["209.131.36.158"]["time"] = one_minute_less_than_a_day_ago.to_s

    name = @apl.lookup_ip_address("209.131.36.158")

    # check that it is looked up, and that the time is not the old one from above
    assert(@apl.dns_cache["209.131.36.158"]["name"].match("yahoo\.com"))
    assert_equal(2, @apl.dns_cache.length)
    assert_not_equal(one_minute_less_than_a_day_ago.to_s, @apl.dns_cache["209.131.36.158"]["time"])
 
    # check that the age is less than a day in the current cache item 
    cache_item_age = Time.now - Time.parse(@apl.dns_cache["209.131.36.158"]["time"]) 
    assert(cache_item_age < 86400)
  end

  def test_get_ip_from_line
    log_line = "208.77.188.166 - - [29/Apr/2009:16:07:38 -0700] \"GET / HTTP/1.1\" 200 1342"

    assert_equal("208.77.188.166", @apl.get_ip(log_line))
  end
 
  def test_process_line
    log_line = "127.0.0.1 - - [29/Apr/2009:16:07:38 -0700] \"GET / HTTP/1.1\" 200 1342"
    log_line_processed_expected = "localhost - - [29/Apr/2009:16:07:38 -0700] \"GET / HTTP/1.1\" 200 1342"

    assert_equal(log_line_processed_expected, @apl.process_line(log_line))
  end

  def test_process_file_contents
    @apl.read_log_file
    @apl.process_lines

    index = 0
    @apl.parsed_lines.each do |parsed_line|
      assert_equal(@apl.log_lines[index][:line].gsub(/(\d+)\.(\d+)\.(\d+)\.(\d+)/, "localhost") ,parsed_line)
    end
  end
end
