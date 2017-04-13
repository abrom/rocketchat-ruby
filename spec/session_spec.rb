require 'spec_helper'

describe RocketChat::Session do
  let(:server) { RocketChat::Server.new(SERVER_URI) }
  let(:token) { RocketChat::Token.new(authToken: AUTH_TOKEN, userId: USER_ID) }
  let(:session) { RocketChat::Session.new(server, token) }

  describe '#logout' do
    before do
      # Stubs for /api/v1/logout REST API
      stub_request(:post, SERVER_URI + '/api/v1/logout')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_request(:post, SERVER_URI + '/api/v1/logout')
        .with(headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID })
        .to_return(
          body: {
            status: :success,
            data: { message: "You've been logged out!" }
          }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'should be success' do
        expect(session.logout).to be_nil
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.logout
        end.to raise_error RocketChat::StatusError
      end
    end
  end
end
