require 'spec_helper'

describe RocketChat::Messages::Chat do
  let(:server) { RocketChat::Server.new(SERVER_URI) }
  let(:token) { RocketChat::Token.new(authToken: AUTH_TOKEN, userId: USER_ID) }
  let(:session) { RocketChat::Session.new(server, token) }

  describe '#delete' do
    before do
      # Stubs for /api/v1/chat.delete REST API
      stub_unauthed_request :post, '/api/v1/chat.delete'

      stub_authed_request(:post, '/api/v1/chat.delete')
        .with(
          body: {
            roomId: '1234',
            msgId: 'not_found'
          }.to_json
        ).to_return(
          body: {
            success: false,
            error: 'No message found with the id of "not_found".'
          }.to_json,
          status: 400
        )

      stub_authed_request(:post, '/api/v1/chat.delete')
        .with(
          body: {
            roomId: '1234',
            msgId: 'valid_msg_id'
          }.to_json
        ).to_return(
          body: {
            _id: 'valid_msg_id',
            ts: 1481741940895,
            success: true
          }.to_json,
          status: 200
        )

      stub_authed_request(:post, '/api/v1/chat.delete')
        .with(
          body: {
            roomId: '1234',
            msgId: 'valid_msg_user_id',
            asUser: true
          }.to_json
        ).to_return(
          body: {
            _id: 'valid_msg_user_id',
            ts: 1481741940456,
            success: true
          }.to_json,
          status: 200
        )

      stub_authed_request(:post, '/api/v1/chat.delete')
        .with(
          body: {
            roomName: 'room',
            msgId: 'valid_room_msg_id'
          }.to_json
        ).to_return(
          body: {
            _id: 'valid_room_msg_id',
            ts: 1481741940123,
            success: true
          }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'returns success for room id' do
        expect(session.chat.delete(room_id: '1234', msg_id: 'valid_msg_id')).to be_truthy
      end

      it 'returns success for room name' do
        expect(session.chat.delete(name: 'room', msg_id: 'valid_room_msg_id')).to be_truthy
      end

      it 'passes through `asUser` and return success' do
        expect(
          session.chat.delete(room_id: '1234', msg_id: 'valid_msg_user_id', as_user: true)
        ).to be_truthy
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.chat.delete room_id: '1234', msg_id: 'valid_id'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end

    context 'message doesnt belong to room' do
      it 'raises a status error' do
        expect do
          session.chat.delete room_id: '1234', msg_id: 'not_found'
        end.to raise_error RocketChat::StatusError, 'No message found with the id of "not_found".'
      end
    end
  end

  describe '#get_message' do
    before do
      # Stubs for /api/v1/chat.getMessage REST API
      stub_unauthed_request :get, '/api/v1/chat.getMessage?msgId=other_valid_id'

      stub_authed_request(:get, '/api/v1/chat.getMessage?msgId=not_found')
        .to_return(
          body: { success: false }.to_json,
          status: 400
        )

      stub_authed_request(:get, '/api/v1/chat.getMessage?msgId=valid_msg_id')
        .to_return(
          body: {
            success: true,
            message: {
              alias: '',
              msg: 'This is a test!',
              parseUrls: true,
              groupable: false,
              ts: '2016-12-14T20:56:05.117Z',
              u: {
                _id: 'y65tAmHs93aDChMWu',
                username: 'graywolf336'
              },
              rid: 'GENERAL',
              _updatedAt: '2016-12-14T20:56:05.119Z',
              _id: 'jC9chsFddTvsbFQG7'
            }
          }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'returns message for room id' do
        message = session.chat.get_message msg_id: 'valid_msg_id'
        expect(message).to be_a RocketChat::Message
        expect(message.message).to eq 'This is a test!'
      end
    end

    context 'message not found' do
      it 'raises a status error' do
        expect do
          session.chat.get_message msg_id: 'not_found'
        end.to raise_error RocketChat::StatusError
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.chat.get_message msg_id: 'other_valid_id'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#post_message' do
    before do
      # Stubs for /api/v1/chat.postMessage REST API
      stub_unauthed_request :post, '/api/v1/chat.postMessage'

      stub_authed_request(:post, '/api/v1/chat.postMessage')
        .with(
          body: {
            roomId: '1234',
            channel: '#general'
          }.to_json
        ).to_return(
          body: {
            success: false,
            error: 'unknown-error'
          }.to_json,
          status: 400
        )

      stub_authed_request(:post, '/api/v1/chat.postMessage')
        .with(
          body: {
            roomId: '1234',
            channel: '#general',
            text: 'Test message'
          }.to_json
        ).to_return(
          body: {
            success: true,
            channel: 'general',
            message: {
              alias: '',
              msg: 'Test message',
              parseUrls: true,
              groupable: false,
              ts: '2016-12-14T20:56:05.117Z',
              u: {
                _id: 'y65tAmHs93aDChMWu',
                username: 'graywolf336'
              },
              rid: '1234',
              _updatedAt: '2016-12-14T20:56:05.119Z',
              _id: 'jC9chsFddTvsbFQG7'
            }
          }.to_json,
          status: 200
        )

      stub_authed_request(:post, '/api/v1/chat.postMessage')
        .with(
          body: {
            roomId: '1234',
            channel: '#general',
            text: 'Other message'
          }.to_json
        ).to_return(
          body: {
            success: true,
            channel: 'general',
            message: {
              alias: '',
              msg: 'Other message',
              parseUrls: true,
              groupable: false,
              ts: '2016-12-14T20:56:05.117Z',
              u: {
                _id: 'y65tAmHs93aDChMWu',
                username: 'graywolf336'
              },
              rid: '1234',
              _updatedAt: '2016-12-14T20:56:05.119Z',
              _id: 'jC9chsFddTvsbFQG7'
            }
          }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'returns message for room id' do
        message = session.chat.post_message room_id: '1234', channel: '#general', text: 'Test message'
        expect(message).to be_a RocketChat::Message
        expect(message.message).to eq 'Test message'
      end

      it 'does not send unknown attributes' do
        message = session.chat.post_message(
          room_id: '1234', channel: '#general', text: 'Other message', foo: 'bar'
        )
        expect(message).to be_a RocketChat::Message
        expect(message.message).to eq 'Other message'
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.chat.post_message room_id: '1234', channel: '#general', text: 'Sample message'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end

    context 'message isnt provided' do
      it 'raises a status error' do
        expect do
          session.chat.post_message room_id: '1234', channel: '#general'
        end.to raise_error RocketChat::StatusError, 'unknown-error'
      end
    end
  end

  describe '#update' do
    before do
      # Stubs for /api/v1/chat.update REST API
      stub_unauthed_request :post, '/api/v1/chat.update'

      stub_authed_request(:post, '/api/v1/chat.update')
        .with(
          body: {
            roomId: '1234',
            msgId: 'not_found',
            text: 'Failing update message'
          }.to_json
        ).to_return(
          body: {
            success: false,
            error: 'No message found with the id of "not_found".'
          }.to_json,
          status: 400
        )

      stub_authed_request(:post, '/api/v1/chat.update')
        .with(
          body: {
            roomId: '1234',
            msgId: 'valid_msg_id',
            text: 'New message'
          }.to_json
        ).to_return(
          body: {
            message: {
              _id: 'valid_msg_id',
              rid: '1234',
              msg: 'New message',
              ts: '2017-01-05T17:06:14.403Z',
              u: {
                _id: 'R4jgcQaQhvvK6K3iY',
                username: 'graywolf336'
              },
              _updatedAt: '2017-01-05T19:42:20.433Z',
              editedAt: '2017-01-05T19:42:20.431Z',
              editedBy: {
                _id: 'R4jgcQaQhvvK6K3iY',
                username: 'graywolf336'
              }
            },
            success: true
          }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'returns message for room id' do
        message = session.chat.update room_id: '1234', msg_id: 'valid_msg_id', text: 'New message'
        expect(message).to be_a RocketChat::Message
        expect(message.message).to eq 'New message'
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.chat.update room_id: '1234', msg_id: 'valid_id', text: 'Not logged in'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end

    context 'message doesnt belong to room' do
      it 'raises a status error' do
        expect do
          session.chat.update room_id: '1234', msg_id: 'not_found', text: 'Failing update message'
        end.to raise_error RocketChat::StatusError, 'No message found with the id of "not_found".'
      end
    end
  end
end
