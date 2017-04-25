require 'spec_helper'

def user_for_request(name, extras={})
  split = name.downcase.split(' ')
  {
    username: split.join('_'),
    email: extras[:email] || "#{split.join('@')}.com",
    name: name,
    password: '123456',
  }.merge(extras)
end

def full_response(request_data)
  {
    body: {
      success: true,
      user: {
        _id: '1234',
        username: request_data[:username],
        emails: [
          { address: request_data[:email], verified: false }
        ],
        type: 'user',
        status: 'online',
        active: request_data.fetch(:active, true),
        name: request_data[:name],
      }
    }.to_json,
    status: 200
  }
end

def stub_authed_request(method, action)
  stub_request(method, SERVER_URI + action)
    .with(headers: { 'X-Auth-Token' => AUTH_TOKEN, 'X-User-Id' => USER_ID })
end

describe RocketChat::Messages::User do
  let(:server) { RocketChat::Server.new(SERVER_URI) }
  let(:token) { RocketChat::Token.new(authToken: AUTH_TOKEN, userId: USER_ID) }
  let(:session) { RocketChat::Session.new(server, token) }

  invalid_user_body = {
    body: {
      success: false,
      error: 'The required "userId" or "username" param provided does not match any users [error-invalid-user]',
      errorType: 'error-invalid-user'
    }.to_json,
    status: 400
  }

  not_provided_user_body = {
    body: {
      success: false,
      error: 'The required "userId" or "username" param was not provided [error-user-param-not-provided]',
      errorType: 'error-user-param-not-provided'
    }.to_json,
    status: 400
  }

  describe '#create' do
    before do
      # Stubs for /api/v1/users.create REST API
      stub_request(:post, SERVER_URI + '/api/v1/users.create')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      data = user_for_request('Already Exists')
      stub_authed_request(:post, '/api/v1/users.create')
        .with(
          body: data.to_json
        ).to_return(
          body: {
            success: false,
            error: 'User already exists'
          }.to_json,
          status: 401
        )

      data = user_for_request('New User',
                              active: true,
                              joinDefaultChannels: false)
      stub_authed_request(:post, '/api/v1/users.create')
        .with(
          body: data.to_json
        ).to_return(full_response(data))
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

      stub_authed_request(:post, '/api/v1/users.update')
        .with(
          body: {
            userId: '1234',
            data: {
              email: 'already@exists.com'
            }
          }
        ).to_return(
          body: {
            success: false,
            error: 'Email already in use'
          }.to_json,
          status: 401
        )

      stub_authed_request(:post, '/api/v1/users.update')
        .with(
          body: {
            userId: '1234',
            data: {
              email: 'updated@user.com',
              name: 'Updated User',
              active: false
            }
          }.to_json
        ).to_return full_response(user_for_request('Updated User', username: 'new_user', active: false))
    end

    context 'valid session' do
      it 'should be success' do
        existing_user = session.users.update('1234', email: 'updated@user.com', name: 'Updated User', active: false)

        expect(existing_user.id).to eq '1234'
        expect(existing_user.name).to eq 'Updated User'
        expect(existing_user.email).to eq 'updated@user.com'
        expect(existing_user).not_to be_email_verified
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

  describe '#info' do
    before do
      # Stubs for /api/v1/users.info REST API
      stub_request(:get, SERVER_URI + '/api/v1/users.info?userId=1234')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_authed_request(:get, '/api/v1/users.info?userId=123456')
        .to_return(invalid_user_body)

      stub_authed_request(:get, '/api/v1/users.info?username=invalid-user')
        .to_return(invalid_user_body)

      stub_authed_request(:get, '/api/v1/users.info?username')
        .to_return(not_provided_user_body)

      expected = full_response(user_for_request('Some User'))

      stub_authed_request(:get, '/api/v1/users.info?userId=1234')
        .to_return(expected)

      stub_authed_request(:get, '/api/v1/users.info?username=some_user')
        .to_return(expected)
    end

    context 'valid session' do
      context 'with no user information' do
        it 'should be failure' do
          expect do
            session.users.info(username: nil)
          end.to raise_error RocketChat::StatusError, 'The required "userId" or "username" param was not provided [error-user-param-not-provided]'
        end
      end

      context 'about a missing user' do
        it 'should be nil' do
          expect(session.users.info(userId: '123456')).to be_nil
          expect(session.users.info(username: 'invalid-user')).to be_nil
        end
      end

      context 'by existing userId' do
        it 'should be success' do
          existing_user = session.users.info(userId: '1234')

          expect(existing_user.id).to eq '1234'
          expect(existing_user.name).to eq 'Some User'
          expect(existing_user.email).to eq 'some@user.com'
          expect(existing_user).not_to be_email_verified
          expect(existing_user.status).to eq 'online'
          expect(existing_user.username).to eq 'some_user'
          expect(existing_user).to be_active
        end
      end

      context 'by existing username' do
        it 'should be success' do
          existing_user = session.users.info(username: 'some_user')

          expect(existing_user.id).to eq '1234'
          expect(existing_user.name).to eq 'Some User'
          expect(existing_user.email).to eq 'some@user.com'
          expect(existing_user).not_to be_email_verified
          expect(existing_user.status).to eq 'online'
          expect(existing_user.username).to eq 'some_user'
          expect(existing_user).to be_active
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.info(userId: '1234')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#delete' do
    before do
      # Stubs for /api/v1/users.delete REST API
      stub_request(:post, SERVER_URI + '/api/v1/users.delete')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_authed_request(:post, '/api/v1/users.delete')
        .with(
          body: {userId: '123456'}
        ).to_return(invalid_user_body)

      stub_authed_request(:post, '/api/v1/users.delete')
        .with(
          body: {username: 'invalid-user'}.to_json
        ).to_return(invalid_user_body)

      stub_authed_request(:post, '/api/v1/users.delete')
        .with(
          body: {username: nil}.to_json
        ).to_return(not_provided_user_body)

      stub_authed_request(:post, '/api/v1/users.delete')
        .with(
          body: {userId: '1234'}.to_json
        ).to_return(
        body: {success: true}.to_json,
        status: 200
      )
    end

    context 'valid session' do
      it 'should be success' do
        expect(session.users.delete(userId: '1234')).to be_truthy
      end

      context 'with no user information' do
        it 'should be failure' do
          expect do
            session.users.delete(username: nil)
          end.to raise_error RocketChat::StatusError, 'The required "userId" or "username" param was not provided [error-user-param-not-provided]'
        end
      end

      context 'about a missing user' do
        it 'should be false' do
          expect(session.users.delete(userId: '123456')).to eq false
          expect(session.users.delete(username: 'invalid-user')).to eq false
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.delete(userId: '1234')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#setAvatar' do
    before do
      # Stubs for /api/v1/users.set_avatar REST API
      stub_request(:post, SERVER_URI + '/api/v1/users.setAvatar')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_authed_request(:post, '/api/v1/users.setAvatar')
        .with(
          body: {
            avatarUrl: 'some-image-url',
            userId: '123456'
          }
        ).to_return(
        body: {
          success: false,
          error: "Cannot read property 'username' of undefined"
        }.to_json,
        status: 200
      )

      stub_authed_request(:post, '/api/v1/users.setAvatar')
        .with(
          body: {
            avatarUrl: 'some-image-url',
            userId: '1234'
          }
      ).to_return(
        body: {success: true}.to_json,
        status: 200
      )

      stub_authed_request(:post, '/api/v1/users.setAvatar')
        .with(
          body: {
            avatarUrl: 'some-image-url',
          }
      ).to_return(
        body: {success: true}.to_json,
        status: 200
      )
    end

    context 'valid session' do
      it 'should be success' do
        expect(session.users.set_avatar('some-image-url')).to be_truthy
      end

      context 'with userId parameter' do
        it 'should be success' do
          expect(session.users.set_avatar('some-image-url', userId: '1234')).to be_truthy
        end
      end

      context 'with bad user information' do
        it 'should be failure' do
          expect do
            session.users.set_avatar('some-image-url', userId: '123456')
          end.to raise_error RocketChat::StatusError, "Cannot read property 'username' of undefined"
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.set_avatar(userId: '1234')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end
end
