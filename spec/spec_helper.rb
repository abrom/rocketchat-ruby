# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'rocketchat'

require 'json'
require 'webmock/rspec'

require 'shared/room_behaviors'

SERVER_URI = URI.parse('http://www.example.com/')
AUTH_TOKEN = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
USER_ID = 'AAAAAAAAAAAAAAAAA'
OTHER_USER_ID = 'BBBBBBBBBBBBBBBBB'
ROOM_ID = 'ValidRoomID'
BOGUS_ROOM_ID = 'BogusRoomID'
USERNAME = 'user'
PASSWORD = 'password'

UNAUTHORIZED_MESSAGE = 'You must be logged in to do this.'
UNAUTHORIZED_BODY = {
  status: :error,
  message: UNAUTHORIZED_MESSAGE
}.to_json
UNAUTHORIZED_STATUS = 401
UNAUTHORIZED = { body: UNAUTHORIZED_BODY, status: UNAUTHORIZED_STATUS }.freeze

### Authenticated request helpers

def stub_authed_request(method, action)
  stub_request(method, SERVER_URI + action)
    .with(headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID })
end

def stub_unauthed_request(method, action)
  stub_request(method, SERVER_URI + action)
    .to_return(UNAUTHORIZED)
end
