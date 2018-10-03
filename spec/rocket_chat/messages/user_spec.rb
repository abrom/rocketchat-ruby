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
      stub_unauthed_request :post, '/api/v1/users.create'

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

    context 'with a valid session' do
      subject(:users_create) do
        session.users.create(
          'new_user', 'new@user.com', 'New User', '1236',
          active: true, join_default_channels: false
        )
      end

      it { expect(users_create.id).to eq '1234' }
      it { expect(users_create.name).to eq 'New User' }
      it { expect(users_create.email).to eq 'new@user.com' }
      it { is_expected.not_to be_email_verified }
      it { expect(users_create.status).to eq 'online' }
      it { expect(users_create.username).to eq 'new_user' }
      it { is_expected.to be_active }

      context 'with an existing user' do
        it 'raises a status error' do
          expect do
            session.users.create('already_exists', 'already@exists.com', 'Already Exists', '1236')
          end.to raise_error RocketChat::StatusError, 'User already exists'
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.users.create 'newuser', 'new@user.com', 'New User', 'passw0rd'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#update' do
    before do
      # Stubs for /api/v1/users.update REST API
      stub_unauthed_request :post, '/api/v1/users.update'

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

    context 'with a valid session' do
      subject(:users_update) do
        session.users.update('1234', email: 'updated@user.com', name: 'Updated User', active: false)
      end

      it { expect(users_update.id).to eq '1234' }
      it { expect(users_update.name).to eq 'Updated User' }
      it { expect(users_update.email).to eq 'updated@user.com' }
      it { is_expected.not_to be_email_verified }
      it { expect(users_update.status).to eq 'online' }
      it { expect(users_update.username).to eq 'new_user' }
      it { is_expected.not_to be_active }

      context 'with an existing email' do
        it 'raises a status error' do
          expect do
            session.users.update('1234', email: 'already@exists.com')
          end.to raise_error RocketChat::StatusError, 'Email already in use'
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.users.update('1234', email: 'updated@user.com')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#info' do
    before do
      # Stubs for /api/v1/users.info REST API
      stub_unauthed_request :get, '/api/v1/users.info?userId=1234'

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

    context 'with a valid session' do
      context 'with no user information' do
        it 'raises a status error' do
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

      context 'with an invalid user' do
        it 'returns nil' do
          expect(session.users.info(user_id: '1236')).to be_nil
          expect(session.users.info(username: 'invalid-user')).to be_nil
        end
      end

      context 'when searching by an existing userId' do
        subject(:existing_user) { session.users.info(user_id: '1234') }

        it { expect(existing_user.id).to eq '1234' }
        it { expect(existing_user.name).to eq 'Some User' }
        it { expect(existing_user.email).to eq 'some@user.com' }
        it { expect(existing_user).not_to be_email_verified }
        it { expect(existing_user.status).to eq 'online' }
        it { expect(existing_user.username).to eq 'some_user' }
        it { expect(existing_user).to be_active }
      end

      context 'when searching by an existing username' do
        subject(:existing_user) { session.users.info(username: 'some_user') }

        it { expect(existing_user.id).to eq '1234' }
        it { expect(existing_user.name).to eq 'Some User' }
        it { expect(existing_user.email).to eq 'some@user.com' }
        it { expect(existing_user).not_to be_email_verified }
        it { expect(existing_user.status).to eq 'online' }
        it { expect(existing_user.username).to eq 'some_user' }
        it { expect(existing_user).to be_active }
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
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
      stub_unauthed_request :get, '/api/v1/users.list'

      stub_authed_request(:get, '/api/v1/users.list?query=%7B%22username%22:%22bobsmith%22%7D')
        .to_return(empty_users_body)

      stub_authed_request(:get, '/api/v1/users.list?query=%7B%22username%22:%22rogersmith%22%7D')
        .to_return(found_users_body)

      stub_authed_request(:get, '/api/v1/users.list')
        .to_return(all_users_body)
    end

    context 'with a valid session' do
      context 'when searching for an invalid username' do
        it 'returns empty' do
          users = session.users.list(query: { username: 'bobsmith' })

          expect(users).to be_empty
        end
      end

      context 'when searching for a valid username' do
        it 'returns Roger' do
          users = session.users.list(query: { username: 'rogersmith' })

          expect(users.length).to eq 1
          expect(users[0].id).to eq 123
          expect(users[0].username).to eq 'rogersmith'
        end
      end

      context 'without a filter' do
        it 'returns all users' do
          users = session.users.list

          expect(users.map(&:class)).to eq [RocketChat::User, RocketChat::User]
          expect(users[0].id).to eq 123
          expect(users[0].username).to eq 'rogersmith'
          expect(users[1].id).to eq 124
          expect(users[1].username).to eq 'cynthiasmith'
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
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
      stub_unauthed_request :get, "/api/v1/users.getPresence?userId=#{USER_ID}"

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

    context 'with a valid session' do
      it 'returns full presence status for user id' do
        status = session.users.get_presence(user_id: USER_ID)
        expect(status.presence).to eq 'offline'
        expect(status.connection_status).to eq 'offline'
        expect(status.last_login).to be_within(1).of Time.new(2016, 12, 8, 18, 26, 3, '+00:00')
      end

      it 'returns full presence status for username' do
        status = session.users.get_presence(username: USERNAME)
        expect(status.presence).to eq 'offline'
        expect(status.connection_status).to eq 'offline'
        expect(status.last_login).to be_within(1).of Time.new(2016, 12, 8, 18, 26, 3, '+00:00')
      end

      context 'when requesting a different user' do
        it 'returns partial presence status' do
          status = session.users.get_presence(user_id: OTHER_USER_ID)
          expect(status.presence).to eq 'online'
          expect(status.connection_status).to be_nil
          expect(status.last_login).to be_nil
        end
      end

      context 'with an invalid user' do
        it 'raises a status error for invalid user id' do
          expect do
            session.users.get_presence(user_id: '1236')
          end.to(
            raise_error(
              RocketChat::StatusError,
              'The required "userId" or "username" param provided does not match any users [error-invalid-user]'
            )
          )
        end

        it 'raises a status error for invalid username' do
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

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.users.get_presence(user_id: USER_ID)
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#delete' do
    before do
      # Stubs for /api/v1/users.delete REST API
      stub_unauthed_request :post, '/api/v1/users.delete'

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

    context 'with a valid session' do
      it 'returns success' do
        expect(session.users.delete(user_id: '1234')).to be_truthy
      end

      context 'with no user information' do
        it 'raises a status error' do
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

      context 'with an invalid user' do
        it 'returns false' do
          expect(session.users.delete(user_id: '1236')).to eq false
          expect(session.users.delete(username: 'invalid-user')).to eq false
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.users.delete(user_id: '1234')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#reset_avatar' do
    before do
      # Stubs for /api/v1/users.resetAvatar REST API
      stub_unauthed_request :post, '/api/v1/users.resetAvatar'

      stub_authed_request(:post, '/api/v1/users.resetAvatar')
        .with(
          body: {}
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )

      stub_authed_request(:post, '/api/v1/users.resetAvatar')
        .with(
          body: {
            userId: '1236'
          }
        ).to_return(
          body: {
            success: false,
            error: "Cannot read property 'username' of undefined"
          }.to_json,
          status: 200
        )

      stub_authed_request(:post, '/api/v1/users.resetAvatar')
        .with(
          body: {
            userId: '1234'
          }
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it 'returns success' do
        expect(session.users.reset_avatar).to be_truthy
      end

      context 'with user_id parameter' do
        it 'returns success' do
          expect(session.users.reset_avatar(user_id: '1234')).to be_truthy
        end
      end

      context 'with bad user information' do
        it 'raises a status error' do
          expect do
            session.users.reset_avatar(user_id: '1236')
          end.to raise_error RocketChat::StatusError, "Cannot read property 'username' of undefined"
        end
      end
    end
  end

  describe '#set_avatar' do
    before do
      # Stubs for /api/v1/users.setAvatar REST API
      stub_unauthed_request :post, '/api/v1/users.setAvatar'

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

    context 'with a valid session' do
      it 'returns success' do
        expect(session.users.set_avatar('some-image-url')).to be_truthy
      end

      context 'with user_id parameter' do
        it 'returns success' do
          expect(session.users.set_avatar('some-image-url', user_id: '1234')).to be_truthy
        end
      end

      context 'with bad user information' do
        it 'raises a status error' do
          expect do
            session.users.set_avatar('some-image-url', user_id: '1236')
          end.to raise_error RocketChat::StatusError, "Cannot read property 'username' of undefined"
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
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
