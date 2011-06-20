require 'rubygems'
require 'test/unit'

require 'bundler'
Bundler.setup(:default, :development)

require 'time'

require 'active_support/core_ext/object/blank'
require 'active_support/time_with_zone'

if ENV['LEFTRIGHT']
  begin
    require 'leftright'
  rescue LoadError
    puts "Run `gem install leftright` to install leftright."
  end
end

unless $LOAD_PATH.include? 'lib'
  $LOAD_PATH.unshift(File.dirname(__FILE__))
  $LOAD_PATH.unshift(File.join($LOAD_PATH.first, '..', 'lib'))
end

require 'faraday'
require 'faraday/auth-hmac'

begin
  require 'ruby-debug'
rescue LoadError
  # ignore
else
  Debugger.start
end

module Faraday
  class TestCase < Test::Unit::TestCase
    def test_default
      assert true
    end unless defined? ::MiniTest
  end
end
