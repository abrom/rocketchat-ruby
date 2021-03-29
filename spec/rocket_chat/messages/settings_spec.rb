# frozen_string_literal: true

require 'spec_helper'

describe RocketChat::Messages::Settings do
  let(:server) { RocketChat::Server.new(SERVER_URI) }
  let(:token) { RocketChat::Token.new(authToken: AUTH_TOKEN, userId: USER_ID) }
  let(:session) { RocketChat::Session.new(server, token) }

  describe '#[]' do
    before do
      # Stubs for /api/v1/settings/_id REST API
      stub_unauthed_request :get, '/api/v1/settings/foo'

      stub_authed_request(:get, "#{SERVER_URI}/api/v1/settings/foo")
        .to_return(
          body: {
            _id: 'foo',
            value: 'some value',
            success: true
          }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it 'returns the value' do
        expect(session.settings['foo']).to eq 'some value'
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.settings['foo']
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#[]=' do
    before do
      # Stubs for /api/v1/settings/_id REST API
      stub_request(:post, "#{SERVER_URI}/api/v1/settings/foo")
        .with(
          body: { value: '1234' }.to_json
        ).to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_authed_request(:post, "#{SERVER_URI}/api/v1/settings/foo")
        .with(
          body: { value: '1234' }.to_json
        ).to_return(
          body: {
            success: true
          }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it 'returns value' do
        expect(session.settings['foo'] = '1234').to eq '1234'
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.settings['foo'] = '1234'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end
end
