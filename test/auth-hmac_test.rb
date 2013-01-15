require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class AuthHMACMiddlewareTest < Faraday::TestCase
  def setup
    Faraday::Request::AuthHMAC.keys.clear
    @access_id, @secret = "id", "secret"
    @conn = Faraday.new do |req|
      req.request :auth_hmac
      req.adapter :test do |stub|
        stub.post('/echo') do |env|
          posted_as = env[:request_headers]['Content-Type']
          [200, {'Content-Type' => posted_as}, env[:body]]
        end
      end
    end
  end

  def test_auth_hmac_skips_when_sign_is_not_called
    response = @conn.post('/echo', { :some => 'data' }, 'content-type' => 'application/x-foo')
    assert_nil response.env[:request_headers]['Authorization']
  end
  
  def test_request_instructed_to_sign_a_request_will_result_in_a_correctly_signed_request
    response = @conn.post('/echo', { :some => 'data' }, 'content-type' => 'application/x-foo') do |r|
      r.sign! 'access_id', 'secret'
    end
    
    assert signed?(response.env, @access_id, @secret), "should be signed"
  end
  
  def test_a_signed_request_includes_appropriate_headers
    response = @conn.post('/echo', { :some => 'data' }, 'content-type' => 'application/x-foo') do |r|
      r.sign! 'access_id', 'secret'
    end
    
    %w(Authorization Content-MD5 Date).each do |header|
      assert_not_nil response.env[:request_headers][header], "should have #{header} header"
    end
  end

  protected

  def klass
    Faraday::Request::AuthHMAC
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
