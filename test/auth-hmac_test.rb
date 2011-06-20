require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
# require 'rack/utils'

class AuthHMACMiddlewareTest < Faraday::TestCase
  def setup
    Faraday::Request::AuthHMAC.keys.clear
    @access_id, @secret = "id", "secret"
    @connection = Faraday.new :url => 'http://sushi.com/api'
    @request    = Faraday::Request.create(:get) do |req|
      req.url 'foo.json'
      req.body = "test"
    end
    generate_env!
  end

  def test_auth_hmac_skips_when_sign_is_not_called
    call(@env)
    assert_nil @env[:request_headers]['Authorization']
  end

  def test_request_will_instruct_middleware_to_sign_if_told_to
    assert_nil @env[:sign_with]

    @request.sign! @access_id, @secret
    generate_env!
    assert_equal @access_id, @env[:sign_with]
  end

  def test_request_instructed_to_sign_a_request_will_result_in_a_correctly_signed_request
    @env[:sign_with] = @access_id
    klass.keys = {@access_id => @secret}

    call(@env)
    assert signed?(@env, @access_id, @secret), "should be signed"
  end

  def test_a_signed_request_includes_appropriate_headers
    @request.sign! @access_id, @secret
    generate_env!
    call(@env)

    %w(Authorization Content-MD5 Date).each do |header|
      assert_not_nil @env[:request_headers][header], "should have #{header} header"
    end
  end

  protected

  def klass
    Faraday::Request::AuthHMAC
  end

  def call(env)
    klass.new(lambda{|_|}).call(env)
  end

  def generate_env!
    @env = @request.to_env(@connection)
  end

  # Based on the `authenticated?` method in auth-hmac.
  # https://github.com/dnclabs/auth-hmac/blob/master/lib/auth-hmac.rb#L252
  def signed?(env, access_id, secret)
    auth  = klass.auth
    rx = Regexp.new("#{klass.options[:service_id]} ([^:]+):(.+)$")
    if md = rx.match(env[:request_headers][klass::AUTH_HEADER])
      access_key_id = md[1]
      hmac = md[2]
      !secret.nil? && hmac == auth.signature(env, secret)
    else
      false
    end
  end

end
