# frozen_string_literal: true

require 'spec_helper'

describe RocketChat::Messages::Im do
  let(:server) { RocketChat::Server.new(SERVER_URI) }
  let(:token) { RocketChat::Token.new(authToken: AUTH_TOKEN, userId: USER_ID) }
  let(:session) { RocketChat::Session.new(server, token) }

  describe '#create' do
    before do
      # Stubs for /api/v1/im.create REST API
      stub_unauthed_request :post, '/api/v1/im.create'
    end

    it 'does not send attributes' do
      expect do
        session.im.create
      end.to raise_error RocketChat::StatusError
    end

    context 'when passing through a single username' do
      before do
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
                usernames: %w[rocket.cat user.test]
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

      it 'create a new direct conversation' do
        im = session.im.create username: 'rocket.cat'
        expect(im).to be_a RocketChat::Room
        expect(im.members).to eq %w[rocket.cat user.test]
      end

      context 'with an invalid session token' do
        let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

        it 'raises a status error' do
          expect do
            session.im.create username: 'rocket.cat'
          end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
        end
      end

      context 'when the user does not exists' do
        it 'raises a status error' do
          expect do
            session.im.create(username: 'non-existent.user')
          end.to raise_error RocketChat::StatusError
        end
      end
    end

    context 'when passing through a multiple usernames' do
      before do
        stub_authed_request(:post, '/api/v1/im.create')
          .with(
            body: {
              usernames: 'rocket.cat,rocket.dog'
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
                usernames: %w[rocket.cat rocket.dog user.test]
              },
              success: true
            }.to_json,
            status: 200
          )
      end

      it 'create a new direct conversation' do
        im = session.im.create usernames: %w[rocket.cat rocket.dog]
        expect(im).to be_a RocketChat::Room
        expect(im.members).to eq %w[rocket.cat rocket.dog user.test]
      end
    end

    context 'when passing through excluding self and multiple usernames' do
      before do
        stub_authed_request(:post, '/api/v1/im.create')
          .with(
            body: {
              usernames: 'rocket.cat,rocket.dog',
              excludeSelf: true
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
                usernames: %w[rocket.cat rocket.dog]
              },
              success: true
            }.to_json,
            status: 200
          )
      end

      it 'create a new direct conversation' do
        im = session.im.create usernames: %w[rocket.cat rocket.dog], exclude_self: true
        expect(im).to be_a RocketChat::Room
        expect(im.members).to eq %w[rocket.cat rocket.dog]
      end
    end
  end

  describe '#delete' do
    before do
      # Stubs for /api/v1/im.delete REST API
      stub_unauthed_request :post, '/api/v1/im.delete'

      stub_authed_request(:post, '/api/v1/im.delete')
        .to_return(
          body: {
            success: false,
            error: 'The parameter "roomId" or "roomName" is required',
            errorType: 'error-roomid-param-not-provided'
          }.to_json,
          status: 400
        )

      stub_authed_request(:post, '/api/v1/im.delete')
        .with(
          body: { roomId: '1236' }
        ).to_return(
          body: {
            success: false,
            error: 'The required "roomId" or "username" param provided does not match any direct message',
            errorType: 'error-room-not-found'
          }.to_json,
          status: 400
        )

      stub_authed_request(:post, '/api/v1/im.delete')
        .with(
          body: { roomId: '1234' }.to_json
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it 'returns success' do
        expect(session.im.delete(room_id: '1234')).to be_truthy
      end

      context 'when setting attribute for an invalid room' do
        it 'returns failure' do
          expect(session.im.delete(room_id: '1236')).to be false
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, roomId: nil) }

      it 'raises a status error' do
        expect do
          session.im.delete(room_id: '1234')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#list_everyone' do
    let(:bob_jim) do
      {
        _id: 'bobjim',
        usernames: %w[bob jim],
        type: 'd'
      }
    end

    let(:sally_wendy) do
      {
        _id: 'sallywendy',
        usernames: %w[sally wendy],
        type: 'd'
      }
    end

    before do
      # Stubs for /api/v1/im.list.everyone REST API
      stub_unauthed_request :get, '/api/v1/im.list.everyone'

      stub_authed_request(
        :get,
        '/api/v1/im.list.everyone?query=%7B%22usernames%22:%7B%22$all%22:%5B%22roger%22,%22frank%22%5D%7D%7D'
      ).to_return(
        body: {
          success: true,
          ims: []
        }.to_json,
        status: 200
      )

      stub_authed_request(
        :get,
        '/api/v1/im.list.everyone?query=%7B%22usernames%22:%7B%22$all%22:%5B%22jim%22,%22bob%22%5D%7D%7D'
      ).to_return(
        body: {
          success: true,
          ims: [bob_jim]
        }.to_json,
        status: 200
      )

      stub_authed_request(:get, '/api/v1/im.list.everyone')
        .to_return(
          body: {
            success: true,
            ims: [bob_jim, sally_wendy]
          }.to_json,
          status: 200
        )
    end

    context 'when searching for an invalid IM group' do
      it 'returns empty' do
        ims = session.im.list_everyone(query: { usernames: { '$all': %w[roger frank] } })

        expect(ims).to be_empty
      end
    end

    context 'when searching for a valid IM group' do
      it 'returns the Jim/Bob IM group' do
        ims = session.im.list_everyone(query: { usernames: { '$all': %w[jim bob] } })

        expect(ims.length).to eq 1
        expect(ims[0].class).to eq RocketChat::Room
        expect(ims[0].id).to eq 'bobjim'
        expect(ims[0].members).to eq %w[bob jim]
      end
    end

    context 'without a filter' do
      it 'returns all IM groups' do
        ims = session.im.list_everyone

        expect(ims.map(&:class)).to eq [RocketChat::Room, RocketChat::Room]
        expect(ims[0].id).to eq 'bobjim'
        expect(ims[0].members).to eq %w[bob jim]
        expect(ims[1].id).to eq 'sallywendy'
        expect(ims[1].members).to eq %w[sally wendy]
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, userId: nil) }

      it 'raises a status error' do
        expect do
          session.im.list_everyone
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#counters' do
    before do
      stub_unauthed_request :get, "/api/v1/im.counters?roomId=#{ROOM_ID}"

      stub_authed_request(:get, "/api/v1/im.counters?roomId=#{ROOM_ID}")
        .to_return(
          body: {
            joined: true,
            members: 2,
            unreads: 3,
            unreadsFrom: '2019-01-01T12:34:56.789Z',
            msgs: 4,
            latest: '2019-01-23T01:23:45.678Z',
            userMentions: 5,
            success: true
          }.to_json,
          status: 200
        )

      stub_authed_request(:get, "/api/v1/im.counters?roomId=#{BOGUS_ROOM_ID}")
        .to_return(UNAUTHORIZED)

      stub_authed_request(:get, '/api/v1/im.counters?roomId=')
        .to_return(
          body: {
            success: false,
            error: 'Query param "roomId" is required [error-room-param-not-provided]',
            errorType: 'error-room-param-not-provided'
          }.to_json,
          status: 400
        )

      stub_authed_request(:get, "/api/v1/im.counters?roomId=#{ROOM_ID}&userId=#{USER_ID}")
        .to_return(UNAUTHORIZED)
    end

    context 'when called with valid room_id' do
      it 'returns counters for that DM room' do # rubocop:disable RSpec/MultipleExpectations
        counters = session.im.counters room_id: ROOM_ID
        expect(counters).to be_a RocketChat::ImSummary
        expect(counters.joined).to be true
        expect(counters.members).to eq 2
        expect(counters.unreads).to eq 3
        expect(counters.unreads_from).to eq '2019-01-01T12:34:56.789Z'
        expect(counters.msgs).to eq 4
        expect(counters.latest).to eq '2019-01-23T01:23:45.678Z'
        expect(counters.user_mentions).to eq 5
      end
    end

    context 'when called with bogus room_id' do
      it 'raises StatusError' do
        expect do
          session.im.counters room_id: BOGUS_ROOM_ID
        end.to raise_error RocketChat::StatusError, UNAUTHORIZED_MESSAGE
      end
    end

    context 'when called with blank room_id' do
      it 'raises StatusError' do
        expect do
          session.im.counters room_id: ''
        end.to raise_error RocketChat::StatusError, 'Query param "roomId" is required [error-room-param-not-provided]'
      end
    end

    context 'when called without room_id' do
      it 'raises ArgumentError' do
        expect do
          session.im.counters
        end.to raise_error ArgumentError
      end
    end

    context 'when called with user_id' do
      context 'when you do not have view-room-administration permission' do
        it 'raises error' do
          expect do
            session.im.counters room_id: ROOM_ID, user_id: USER_ID
          end.to raise_error RocketChat::StatusError, UNAUTHORIZED_MESSAGE
        end
      end
    end

    context 'when called with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: 'bogus-token', userId: USER_ID) }

      it 'raises error' do
        expect do
          session.im.counters room_id: ROOM_ID
        end.to raise_error RocketChat::StatusError, UNAUTHORIZED_MESSAGE
      end
    end
  end
end
