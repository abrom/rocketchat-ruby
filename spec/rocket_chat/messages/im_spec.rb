require 'spec_helper'

describe RocketChat::Messages::Im do
  let(:server) { RocketChat::Server.new(SERVER_URI) }
  let(:token) { RocketChat::Token.new(authToken: AUTH_TOKEN, userId: USER_ID) }
  let(:session) { RocketChat::Session.new(server, token) }

  describe '#create' do
    before do
      # Stubs for /api/v1/im.create REST API
      stub_unauthed_request :post, '/api/v1/im.create'

      stub_authed_request(:post, '/api/v1/im.create')
        .with(
          body: {
            username: 'rocket.cat'
          }.to_json
        ).to_return(
          body: {
            room: {
              _id: 'Lymsiu4Mn6xjTAan4RtMDEYc28fQ5aHpf4',
              _updatedAt: '2018-03-26T19:11:50.711Z',
              t: 'd',
              msgs: 0,
              ts: '2018-03-26T19:11:50.711Z',
              meta: {
                revision: 0,
                created: 1522094603745,
                version: 0
              },
              '$loki': 65,
              usernames: [
                'rocket.cat',
                'user.test'
              ]
            },
            success: true
          }.to_json,
          status: 200
        )

      stub_authed_request(:post, '/api/v1/im.create')
        .with(
          body: {
            username: 'non-existent.user'
          }
        ).to_return(
          body: { success: false }.to_json,
          status: 400
        )
    end

    context 'with a valid session' do
      it 'create a new direct conversation' do
        im = session.im.create username: 'rocket.cat'
        expect(im).to be_a RocketChat::Room
        expect(im.members).to eq %w[rocket.cat user.test]
      end

      it 'does not send attributes' do
        expect do
          session.im.create(username: nil)
        end.to raise_error RocketChat::StatusError
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.im.create username: 'rocket.cat'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end

    context 'when the user no exists' do
      it 'raises a status error' do
        expect do
          session.im.create(username: 'non-existent.user')
        end.to raise_error RocketChat::StatusError
      end
    end
  end

  describe '#counters' do
    before do
      stub_unauthed_request :get, '/api/v1/im.counters?roomId=rocket.cat&username='

      stub_authed_request(:get, '/api/v1/im.counters?roomId=rocket.cat&username=')
        .to_return(
          body: {
            joined: true,
            members: 2,
            unreads: 0,
            unreadsFrom: '2019-01-04T21:40:11.251Z',
            msgs: 0,
            latest: '2019-01-04T21:40:11.251Z',
            userMentions: 0,
            success: true
          }.to_json,
          status: 200
        )

      stub_authed_request(:get, '/api/v1/im.counters?roomId=rocket.cat&username=user.test')
        .to_return(
          body: {
            joined: true,
            members: 2,
            unreads: 1,
            unreadsFrom: '2019-01-05T20:37:09.130Z',
            msgs: 0,
            latest: '2019-01-05T20:37:09.130Z',
            userMentions: 0,
            success: true
          }.to_json,
          status: 200
        )

      stub_authed_request(:get, '/api/v1/im.counters?roomId=1234&username=')
        .to_return(
          body: {
            success: false,
            error: '[invalid-channel]',
            errorType: 'invalid-channel'
          }.to_json,
          status: 400
        )

      stub_authed_request(:get, '/api/v1/im.counters?roomId=&username=')
        .to_return(
          body: {
            success: false,
            error: 'Body param "roomId" or "username" is required [error-room-param-not-provided]',
            errorType: 'error-room-param-not-provided'
          }.to_json,
          status: 400
        )
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.im.counters room_id: 'rocket.cat'
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end

    context 'with a valid session' do
      it 'get quantity of messages' do
        im = session.im.counters room_id: 'rocket.cat'
        expect(im).to be_a RocketChat::ImSummary
        expect(im.members).to eq 2
        expect(im.unreads).to eq 0
        expect(im.msgs).to eq 0
        expect(im.user_mentions).to eq 0
      end

      it 'get quantity of messages specifying the username' do
        im = session.im.counters room_id: 'rocket.cat', username: 'user.test'
        expect(im.joined).to eq true
        expect(im.unreads_from).to eq '2019-01-05T20:37:09.130Z'
        expect(im.latest).to eq '2019-01-05T20:37:09.130Z'
        expect(im.success).to eq true
      end

      it 'does not send valid attributes' do
        expect do
          session.im.counters room_id: '1234'
        end.to raise_error RocketChat::StatusError
      end

      it 'does not send any attributes' do
        expect do
          session.im.counters room_id: '', username: ''
        end.to raise_error RocketChat::StatusError
      end
    end
  end
end
