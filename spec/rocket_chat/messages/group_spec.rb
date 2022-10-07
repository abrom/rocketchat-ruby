# frozen_string_literal: true

require 'spec_helper'

describe RocketChat::Messages::Group do
  let(:missing_room_error) do
    'The required "roomId" or "roomName" param provided does not match any group [error-room-not-found]'
  end

  include_examples 'room_behavior', room_type: 'p', query: false

  describe '#add_leader' do
    before do
      # Stubs for /api/v1/groups.addLeader REST API
      stub_unauthed_request :post, '/api/v1/groups.addLeader'

      stub_authed_request(:post, '/api/v1/groups.addLeader')
        .to_return(not_provided_room_body)

      stub_authed_request(:post, '/api/v1/groups.addLeader')
        .with(
          body: { roomId: 'missing-room', userId: '1' }
        ).to_return(invalid_room_body)

      stub_authed_request(:post, '/api/v1/groups.addLeader')
        .with(
          body: { roomId: 'a-room', userId: '1' }
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it 'returns success' do
        expect(scope.add_leader(room_id: 'a-room', user_id: '1')).to be_truthy
      end

      context 'with a missing room' do
        it 'raises a status error' do
          expect do
            scope.add_leader(room_id: 'missing-room', user_id: '1')
          end.to raise_error RocketChat::StatusError, missing_room_error
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, roomId: nil) }

      it 'raises a status error' do
        expect do
          scope.add_leader(room_id: 'a-room', user_id: 'test')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#remove_leader' do
    before do
      # Stubs for /api/v1/groups.removeLeader REST API
      stub_unauthed_request :post, '/api/v1/groups.removeLeader'

      stub_authed_request(:post, '/api/v1/groups.removeLeader')
        .to_return(not_provided_room_body)

      stub_authed_request(:post, '/api/v1/groups.removeLeader')
        .with(
          body: { roomId: 'missing-room', userId: '1' }
        ).to_return(invalid_room_body)

      stub_authed_request(:post, '/api/v1/groups.removeLeader')
        .with(
          body: { roomId: 'a-room', userId: '1' }
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it 'returns success' do
        expect(scope.remove_leader(room_id: 'a-room', user_id: '1')).to be_truthy
      end

      context 'with a missing room' do
        it 'raises a status error' do
          expect do
            scope.remove_leader(room_id: 'missing-room', user_id: '1')
          end.to raise_error RocketChat::StatusError, missing_room_error
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, roomId: nil) }

      it 'raises a status error' do
        expect do
          scope.remove_leader(room_id: 'a-room', user_id: 'test')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#list_all' do
    let(:room1) do
      {
        _id: 123,
        name: 'room-one'
      }
    end

    let(:room2) do
      {
        _id: 124,
        name: 'room-two'
      }
    end

    let(:empty_rooms_body) do
      {
        body: {
          success: true,
          groups: []
        }.to_json,
        status: 200
      }
    end

    let(:found_rooms_body) do
      {
        body: {
          success: true,
          groups: [room1]
        }.to_json,
        status: 200
      }
    end

    let(:all_rooms_body) do
      {
        body: {
          success: true,
          groups: [room1, room2]
        }.to_json,
        status: 200
      }
    end

    before do
      # Stubs for /api/v1/groups.listAll REST API
      stub_unauthed_request :get, '/api/v1/groups.listAll'

      stub_authed_request(
        :get,
        '/api/v1/groups.listAll?query=%7B%22name%22:%22wrong-room%22%7D'
      ).to_return(empty_rooms_body)

      stub_authed_request(
        :get,
        '/api/v1/groups.listAll?query=%7B%22name%22:%22room-one%22%7D'
      ).to_return(found_rooms_body)

      stub_authed_request(:get, '/api/v1/groups.listAll')
        .to_return(all_rooms_body)
    end

    context 'with a valid session' do
      context 'when searching for an invalid room name' do
        it 'is empty' do
          rooms = scope.list_all(query: { name: 'wrong-room' })

          expect(rooms).to be_empty
        end
      end

      context 'when searching for a valid room name' do
        it 'returns room1' do
          rooms = scope.list_all(query: { name: 'room-one' })

          expect(rooms.length).to eq 1
          expect(rooms[0].id).to eq 123
          expect(rooms[0].name).to eq 'room-one'
        end
      end

      context 'without a filter' do
        it 'returns all rooms' do
          rooms = scope.list_all

          expect(rooms.map(&:class)).to eq [RocketChat::Room, RocketChat::Room]
          expect(rooms[0].id).to eq 123
          expect(rooms[0].name).to eq 'room-one'
          expect(rooms[1].id).to eq 124
          expect(rooms[1].name).to eq 'room-two'
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, groupId: nil) }

      it 'raises a status error' do
        expect do
          scope.list_all
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#online' do
    let(:online_users_response) do
      {
        body: {
          success: true,
          online: [
            {
              _id: 'rocketID1',
              username: 'rocketUserName1'
            },
            {
              _id: 'rocketID2',
              username: 'rocketUserName2'
            }
          ]
        }.to_json,
        status: 200
      }
    end

    let(:empty_room_response) do
      {
        body: {
          success: true,
          online: []
        }.to_json,
        status: 200
      }
    end

    let(:invalid_room_response) do
      {
        body: {
          success: false,
          error: 'Group does not exists'
        }.to_json,
        status: 400
      }
    end

    before do
      # Stubs for /api/v1/groups.online REST API
      stub_unauthed_request :get, described_class.api_path('online?query=%7B%22name%22:%22authed%22%7D')

      stub_authed_request(:get, described_class.api_path('online?query=%7B%22name%22:%22wrong-room%22%7D'))
        .to_return(invalid_room_response)

      stub_authed_request(:get, described_class.api_path('online?query=%7B%22name%22:%22room-one%22%7D'))
        .to_return(online_users_response)

      stub_authed_request(:get, described_class.api_path('online?query=%7B%22_id%22:%22TZtANZwQt369rR4UR%22%7D'))
        .to_return(online_users_response)

      stub_authed_request(:get, described_class.api_path('online?query=%7B%22name%22:%22empty-room%22%7D'))
        .to_return(empty_room_response)
    end

    context 'with an invalid room name' do
      it 'raises a group existence error' do
        expect do
          scope.online(name: 'wrong-room')
        end.to raise_error RocketChat::StatusError, 'Group does not exists'
      end
    end

    context 'with a valid room name' do
      it 'returns no users for an empty room' do
        expect(scope.online(name: 'empty-room')).to eq []
      end

      it 'returns online users for a filled room' do
        online_users = scope.online(name: 'room-one')

        expect(online_users.map(&:class)).to eq [RocketChat::User, RocketChat::User]
        expect(online_users[0].id).to eq 'rocketID1'
        expect(online_users[0].username).to eq 'rocketUserName1'
        expect(online_users[1].id).to eq 'rocketID2'
        expect(online_users[1].username).to eq 'rocketUserName2'
      end
    end

    context 'with a valid room id' do
      it 'returns online users for a filled room' do
        online_users = scope.online(room_id: 'TZtANZwQt369rR4UR')

        expect(online_users.map(&:class)).to eq [RocketChat::User, RocketChat::User]
        expect(online_users[0].id).to eq 'rocketID1'
        expect(online_users[0].username).to eq 'rocketUserName1'
        expect(online_users[1].id).to eq 'rocketID2'
        expect(online_users[1].username).to eq 'rocketUserName2'
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, groupId: nil) }

      it 'raises an authentication status error' do
        expect do
          scope.online(name: 'authed')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#kick' do
    before do
      # Stubs for /api/v1/groups.kick REST API
      stub_unauthed_request :post, '/api/v1/groups.kick'

      stub_authed_request(:post, '/api/v1/groups.kick')
        .to_return(not_provided_room_body)

      stub_authed_request(:post, '/api/v1/groups.kick')
        .with(
          body: { roomId: 'missing-room', userId: '1' }
        ).to_return(invalid_room_body)

      stub_authed_request(:post, '/api/v1/groups.kick')
        .with(
          body: { roomId: 'a-room', userId: '1' }
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'with a valid session' do
      it 'returns success' do
        expect(scope.kick(room_id: 'a-room', user_id: '1')).to be_truthy
      end

      context 'with a missing room' do
        it 'raises a status error' do
          expect do
            scope.kick(room_id: 'missing-room', user_id: '1')
          end.to raise_error RocketChat::StatusError, invalid_room_message
        end
      end
    end

    context 'with an invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, roomId: nil) }

      it 'raises a status error' do
        expect do
          scope.kick(room_id: 'a-room', user_id: 'test')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end
end
