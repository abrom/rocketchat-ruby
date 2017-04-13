require 'spec_helper'

describe RocketChat::Server do
  let(:server) { RocketChat::Server.new(SERVER_URI) }

  describe '#info' do
    before do
      # Stub for /api/v1/info REST API
      stub_request(:get, SERVER_URI + '/api/v1/info').to_return(
        body: {
          status: :success,
          info: {
            version: '0.5'
          }
        }.to_json,
        status: 200
      )
    end

    it 'gets server info' do
      info = server.info
      expect(info.version).to eq '0.5'
    end
  end

  describe '#login' do
    before do
      # Stubs for /api/v1/login REST API
      stub_request(:post, SERVER_URI + '/api/v1/login').to_return(
        body: {
          status: :error,
          message: 'Unauthorized'
        }.to_json,
        status: 401
      )

      stub_request(:post, SERVER_URI + '/api/v1/login')
        .with(body: { username: USERNAME, password: PASSWORD })
        .to_return(
          body: {
            status: :success,
            data: { authToken: AUTH_TOKEN, userId: USER_ID }
          }.to_json,
          status: 200
        )
    end

    context 'correct password' do
      it 'should be success' do
        rc = server.login(USERNAME, PASSWORD)
        expect(rc.token.auth_token).to eq AUTH_TOKEN
        expect(rc.token.user_id).to eq USER_ID
      end
    end

    context 'incorrect password' do
      it 'should be failure' do
        expect do
          server.login(USERNAME, PASSWORD + PASSWORD)
        end.to raise_error RocketChat::StatusError, 'Unauthorized'
      end
    end
  end
end
