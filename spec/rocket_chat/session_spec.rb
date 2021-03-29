# frozen_string_literal: true

require 'spec_helper'

describe RocketChat::Session do
  let(:server) { RocketChat::Server.new(SERVER_URI) }
  let(:token) { RocketChat::Token.new(authToken: AUTH_TOKEN, userId: USER_ID) }
  let(:session) { described_class.new(server, token) }

  describe '#logout' do
    before do
      # Stubs for /api/v1/logout REST API
      stub_unauthed_request :post, '/api/v1/logout'

      stub_request(:post, "#{SERVER_URI}api/v1/logout")
        .with(headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID })
        .to_return(
          body: {
            status: :success,
            data: { message: "You've been logged out!" }
          }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it 'returns nil (success)' do
        expect(session.logout).to be_nil
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.logout
        end.to raise_error RocketChat::StatusError
      end
    end
  end

  describe '#me' do
    subject(:me) { session.me }

    before do
      # Stubs for /api/v1/me REST API
      stub_unauthed_request :get, '/api/v1/me'

      stub_request(:get, "#{SERVER_URI}api/v1/me")
        .with(headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID })
        .to_return(
          body: {
            _id: USER_ID,
            name: 'Example User',
            emails: [
              {
                address: 'example@example.com',
                verified: true
              }
            ],
            status: 'online',
            statusConnection: 'offline',
            username: USERNAME,
            utcOffset: 0,
            active: true,
            success: true
          }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it { expect(me.id).to eq USER_ID }
      it { expect(me.name).to eq 'Example User' }
      it { expect(me.email).to eq 'example@example.com' }
      it { expect(me).to be_email_verified }
      it { expect(me.status).to eq 'online' }
      it { expect(me.status_connection).to eq 'offline' }
      it { expect(me.username).to eq USERNAME }
      it { expect(me.utc_offset).to eq 0 }
      it { expect(me).to be_active }
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          me
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end
end
