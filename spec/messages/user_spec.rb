require 'spec_helper'

describe RocketChat::Messages::User do
  let(:server) { RocketChat::Server.new(SERVER_URI) }
  let(:token) { RocketChat::Token.new(authToken: AUTH_TOKEN, userId: USER_ID) }
  let(:session) { RocketChat::Session.new(server, token) }

  describe '#create' do
    before do
      # Stubs for /api/v1/users.create REST API
      stub_request(:post, SERVER_URI + '/api/v1/users.create')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_request(:post, SERVER_URI + '/api/v1/users.create')
        .with(
          headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID },
          body: {
            username: 'already_exists',
            email: 'already@exists.com',
            name: 'Already Exists',
            password: '123456'
          }
        ).to_return(
          body: {
            success: false,
            error: 'User already exists'
          }.to_json,
          status: 401
        )

      stub_request(:post, SERVER_URI + '/api/v1/users.create')
        .with(
          headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID },
          body: {
            username: 'new_user',
            email: 'new@user.com',
            name: 'New User',
            password: '123456',
            active: true,
            joinDefaultChannels: false
          }.to_json
        ).to_return(
          body: {
            success: true,
            user: {
              _id: '1234',
              username: 'new_user',
              emails: [
                { address: 'new@user.com', verified: false }
              ],
              type: 'user',
              status: 'online',
              active: true,
              name: 'New User'
            }
          }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'should be success' do
        new_user = session.users.create(
          'new_user', 'new@user.com', 'New User', '123456',
          active: true, join_default_channels: false
        )

        expect(new_user.id).to eq '1234'
        expect(new_user.name).to eq 'New User'
        expect(new_user.email).to eq 'new@user.com'
        expect(new_user).not_to be_email_verified
        expect(new_user.status).to eq 'online'
        expect(new_user.username).to eq 'new_user'
        expect(new_user).to be_active
      end

      context 'with an existing user' do
        it 'should be failure' do
          expect do
            session.users.create('already_exists', 'already@exists.com', 'Already Exists', '123456')
          end.to raise_error RocketChat::StatusError, 'User already exists'
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.create 'newuser', 'new@user.com', 'New User', 'passw0rd'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#update' do
    before do
      # Stubs for /api/v1/users.update REST API
      stub_request(:post, SERVER_URI + '/api/v1/users.update')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_request(:post, SERVER_URI + '/api/v1/users.update')
        .with(
          headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID },
          body: {
            userId: '1234',
            data: {
              email: 'already@exists.com',
            }
          }
        ).to_return(
        body: {
          success: false,
          error: 'Email already in use'
        }.to_json,
        status: 401
      )

      stub_request(:post, SERVER_URI + '/api/v1/users.update')
        .with(
          headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID },
          body: {
            userId: '1234',
            data: {
              email: 'updated@user.com',
              name: 'Updated User',
              active: false
            }
          }.to_json
        ).to_return(
        body: {
          success: true,
          user: {
            _id: '1234',
            username: 'new_user',
            emails: [
              { address: 'updated@user.com', verified: true }
            ],
            type: 'user',
            status: 'online',
            active: false,
            name: 'Updated User'
          }
        }.to_json,
        status: 200
      )
    end

    context 'valid session' do
      it 'should be success' do
        existing_user = session.users.update('1234', email: 'updated@user.com', name: 'Updated User', active: false)

        expect(existing_user.id).to eq '1234'
        expect(existing_user.name).to eq 'Updated User'
        expect(existing_user.email).to eq 'updated@user.com'
        expect(existing_user).to be_email_verified
        expect(existing_user.status).to eq 'online'
        expect(existing_user.username).to eq 'new_user'
        expect(existing_user).not_to be_active
      end

      context 'with an existing email' do
        it 'should be failure' do
          expect do
            session.users.update('1234', email: 'already@exists.com')
          end.to raise_error RocketChat::StatusError, 'Email already in use'
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.update('1234', email: 'updated@user.com')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end
end
