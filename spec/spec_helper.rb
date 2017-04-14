$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rocketchat'

require 'json'
require 'webmock/rspec'

SERVER_URI = URI.parse('http://www.example.com/')
AUTH_TOKEN = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'.freeze
USER_ID = 'AAAAAAAAAAAAAAAAA'.freeze
USERNAME = 'user'.freeze
PASSWORD = 'password'.freeze
UNAUTHORIZED_BODY = {
  status: :error,
  message: 'You must be logged in to do this.'
}.to_json
