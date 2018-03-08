require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'rocketchat'

require 'json'
require 'webmock/rspec'

require 'shared/room_behaviors'

SERVER_URI = URI.parse('http://www.example.com/')
AUTH_TOKEN = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.freeze
USER_ID = 'AAAAAAAAAAAAAAAAA'.freeze
OTHER_USER_ID = 'BBBBBBBBBBBBBBBBB'.freeze
USERNAME = 'user'.freeze
PASSWORD = 'password'.freeze
UNAUTHORIZED_BODY = {
  status: :error,
  message: 'You must be logged in to do this.'
}.to_json

### Authenticated request helpers

def stub_authed_request(method, action)
  stub_request(method, SERVER_URI + action)
    .with(headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID })
end

def stub_unauthed_request(method, action)
  stub_request(method, SERVER_URI + action)
    .to_return(body: UNAUTHORIZED_BODY, status: 401)
end
