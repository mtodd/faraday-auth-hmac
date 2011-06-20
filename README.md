# Faraday AuthHMAC
## HMAC Signing for Faraday Requests

Enables signing your requests (from Faraday) with AuthHMAC.

## Usage

``` ruby
require 'faraday'
require 'faraday/auth-hmac'

c = Faraday.new do |b|
  b.request :auth_hmac # enables request signing
  b.adapter :net_http
end

c.get('http://localhost/') do |r|
  # signs the request with the access_id and the secret
  r.sign! 'access_id', 'secret'
end
```

## Contributing

* Fork
* Work on a topic branch
* Write tests
* Add/fix/etc
* Create a Pull Request
