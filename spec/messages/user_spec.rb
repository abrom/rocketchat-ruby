require 'spec_helper'

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
          'new_user', 'new@user.com', 'New User', '1236',
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
            session.users.create('already_exists', 'already@exists.com', 'Already Exists', '1236')
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

      stub_authed_request(:get, '/api/v1/users.info?userId=1236')
        .to_return(invalid_user_body)

      stub_authed_request(:get, '/api/v1/users.info?username=invalid-user')
        .to_return(invalid_user_body)

      stub_authed_request(:get, '/api/v1/users.info')
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
          end.to(
            raise_error(
              RocketChat::StatusError,
              'The required "userId" or "username" param was not provided [error-user-param-not-provided]'
            )
          )
        end
      end

      context 'about a missing user' do
        it 'should be nil' do
          expect(session.users.info(user_id: '1236')).to be_nil
          expect(session.users.info(username: 'invalid-user')).to be_nil
        end
      end

      context 'by existing userId' do
        it 'should be success' do
          existing_user = session.users.info(user_id: '1234')

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
          session.users.info(user_id: '1234')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#list' do
    let(:roger) do
      {
        _id: 123,
        username: 'rogersmith'
      }
    end

    let(:cynthia) do
      {
        _id: 124,
        username: 'cynthiasmith'
      }
    end

    let(:empty_users_body) do
      {
        body: {
          success: true,
          users: []
        }.to_json,
        status: 200
      }
    end

    let(:found_users_body) do
      {
        body: {
          success: true,
          users: [roger]
        }.to_json,
        status: 200
      }
    end

    let(:all_users_body) do
      {
        body: {
          success: true,
          users: [roger, cynthia]
        }.to_json,
        status: 200
      }
    end

    before do
      # Stubs for /api/v1/users.list REST API
      stub_request(:get, SERVER_URI + '/api/v1/users.list')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_authed_request(:get, URI.escape('/api/v1/users.list?query={"username":"bobsmith"}'))
        .to_return(empty_users_body)

      stub_authed_request(:get, URI.escape('/api/v1/users.list?query={"username":"rogersmith"}'))
        .to_return(found_users_body)

      stub_authed_request(:get, '/api/v1/users.list')
        .to_return(all_users_body)
    end

    context 'valid session' do
      context 'searching for an invalid username' do
        it 'should be empty' do
          users = session.users.list(query: { username: 'bobsmith' })

          expect(users).to be_empty
        end
      end

      context 'searching for a valid username' do
        it 'should return Roger' do
          users = session.users.list(query: { username: 'rogersmith' })

          expect(users.length).to eq 1
          expect(users[0].id).to eq 123
          expect(users[0].username).to eq 'rogersmith'
        end
      end

      context 'without a filter' do
        it 'should return all users' do
          users = session.users.list

          expect(users.length).to eq 2
          expect(users[0].id).to eq 123
          expect(users[0].username).to eq 'rogersmith'
          expect(users[1].id).to eq 124
          expect(users[1].username).to eq 'cynthiasmith'
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.list
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#get_presence' do
    let(:basic_presence_body) do
      {
        status: 200,
        body: {
          presence: 'online',
          success: true
        }.to_json
      }
    end

    let(:full_presence_body) do
      {
        status: 200,
        body: {
          presence: 'offline',
          connectionStatus: 'offline',
          lastLogin: '2016-12-08T18:26:03.612Z',
          success: true
        }.to_json
      }
    end

    before do
      # Stubs for /api/v1/users.getPresence REST API
      stub_request(:get, SERVER_URI + "/api/v1/users.getPresence?userId=#{USER_ID}")
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      # Invalid user
      stub_authed_request(:get, '/api/v1/users.getPresence?userId=1236')
        .to_return(invalid_user_body)

      stub_authed_request(:get, '/api/v1/users.getPresence?username=invalid-user')
        .to_return(invalid_user_body)

      # Requesting a different user
      stub_authed_request(:get, "/api/v1/users.getPresence?userId=#{OTHER_USER_ID}")
        .to_return(basic_presence_body)

      # Requesting for self
      stub_authed_request(:get, "/api/v1/users.getPresence?userId=#{USER_ID}")
        .to_return(full_presence_body)

      stub_authed_request(:get, "/api/v1/users.getPresence?username=#{USERNAME}")
        .to_return(full_presence_body)
    end

    context 'valid session' do
      it 'should return full presence status for user id' do
        status = session.users.get_presence(user_id: USER_ID)
        expect(status.presence).to eq 'offline'
        expect(status.connection_status).to eq 'offline'
        expect(status.last_login).to be_within(1).of DateTime.new(2016, 12, 8, 18, 26, 3)
      end

      it 'should return full presence status for username' do
        status = session.users.get_presence(username: USERNAME)
        expect(status.presence).to eq 'offline'
        expect(status.connection_status).to eq 'offline'
        expect(status.last_login).to be_within(1).of DateTime.new(2016, 12, 8, 18, 26, 3)
      end

      context 'requesting a different user' do
        it 'should return partial presence status' do
          status = session.users.get_presence(user_id: OTHER_USER_ID)
          expect(status.presence).to eq 'online'
          expect(status.connection_status).to be_nil
          expect(status.last_login).to be_nil
        end
      end

      context 'an invalid user' do
        it 'should return failure for invalid user id' do
          expect do
            session.users.get_presence(user_id: '1236')
          end.to(
            raise_error(
              RocketChat::StatusError,
              'The required "userId" or "username" param provided does not match any users [error-invalid-user]'
            )
          )
        end

        it 'should return failure for invalid username' do
          expect do
            session.users.get_presence(username: 'invalid-user')
          end.to(
            raise_error(
              RocketChat::StatusError,
              'The required "userId" or "username" param provided does not match any users [error-invalid-user]'
            )
          )
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.get_presence(user_id: USER_ID)
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
        .to_return(not_provided_user_body)

      stub_authed_request(:post, '/api/v1/users.delete')
        .with(
          body: { userId: '1236' }
        ).to_return(invalid_user_body)

      stub_authed_request(:post, '/api/v1/users.delete')
        .with(
          body: { username: 'invalid-user' }.to_json
        ).to_return(invalid_user_body)

      stub_authed_request(:post, '/api/v1/users.delete')
        .with(
          body: { userId: '1234' }.to_json
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'should be success' do
        expect(session.users.delete(user_id: '1234')).to be_truthy
      end

      context 'with no user information' do
        it 'should be failure' do
          expect do
            session.users.delete(username: nil)
          end.to(
            raise_error(
              RocketChat::StatusError,
              'The required "userId" or "username" param was not provided [error-user-param-not-provided]'
            )
          )
        end
      end

      context 'about a missing user' do
        it 'should be false' do
          expect(session.users.delete(user_id: '1236')).to eq false
          expect(session.users.delete(username: 'invalid-user')).to eq false
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.delete(user_id: '1234')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#set_avatar' do
    before do
      # Stubs for /api/v1/users.setAvatar REST API
      stub_request(:post, SERVER_URI + '/api/v1/users.setAvatar')
        .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_authed_request(:post, '/api/v1/users.setAvatar')
        .with(
          body: {
            avatarUrl: 'some-image-url',
            userId: '1236'
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
          body: { success: true }.to_json,
          status: 200
        )

      stub_authed_request(:post, '/api/v1/users.setAvatar')
        .with(
          body: {
            avatarUrl: 'some-image-url'
          }
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'should be success' do
        expect(session.users.set_avatar('some-image-url')).to be_truthy
      end

      context 'with user_id parameter' do
        it 'should be success' do
          expect(session.users.set_avatar('some-image-url', user_id: '1234')).to be_truthy
        end
      end

      context 'with bad user information' do
        it 'should be failure' do
          expect do
            session.users.set_avatar('some-image-url', user_id: '1236')
          end.to raise_error RocketChat::StatusError, "Cannot read property 'username' of undefined"
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'should be failure' do
        expect do
          session.users.set_avatar(user_id: '1234')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  ### User request/response helpers

  def user_for_request(name, extras = {})
    split = name.downcase.split(' ')
    {
      username: split.join('_'),
      email: extras[:email] || "#{split.join('@')}.com",
      name: name,
      password: '1236'
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
          name: request_data[:name]
        }
      }.to_json,
      status: 200
    }
  end
end
