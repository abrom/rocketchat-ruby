require 'spec_helper'

describe RocketChat::Messages::Channel do
  include_examples 'room_behavior', room_type: 'c', query: true

  describe '#join' do
    before do
      # Stubs for /api/v1/channels.join REST API
      stub_unauthed_request :post, '/api/v1/channels.join'

      stub_authed_request(:post, '/api/v1/channels.join')
        .to_return(not_provided_room_body)

      stub_authed_request(:post, '/api/v1/channels.join')
        .with(
          body: { roomName: 'missing-room' }
        ).to_return(invalid_room_body)

      stub_authed_request(:post, '/api/v1/channels.join')
        .with(
          body: { roomName: 'a-room' }.to_json
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'should be success' do
        expect(scope.join(name: 'a-room')).to be_truthy
      end

      context 'about a missing room' do
        it 'should raise an error' do
          expect do
            scope.join(name: 'missing-room')
          end.to raise_error(
            RocketChat::StatusError,
            'The required "roomId" or "roomName" param provided does not match any channel [error-room-not-found]'
          )
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, roomId: nil) }

      it 'should be failure' do
        expect do
          scope.join(name: 'a-room')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#online' do
    before do
      # Stubs for /api/v1/channels.online REST API
      stub_unauthed_request :get, '/api/v1/channels.online'

      stub_authed_request(:get, '/api/v1/channels.online')
        .with(
          body: { roomId: '1234' }.to_json
        ).to_return(
          body: {
            success: true,
            online => [
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
        )

      stub_authed_request(:get, '/api/v1/channels.online')
        .with(
          body: { roomId: '1234' }.to_json
        ).to_return(not_provided_room_body)

      stub_authed_request(:get, '/api/v1/channels.online?roomName=invalid-room')
        .to_return(invalid_room_body)
    end

    context 'valid session' do
      it 'should be success' do
        online_in_channel = scope.online(query: { name: '1234' })
        expect(online_in_channel.length).to eq 2
        expect(online_in_channel[0].id).to eq 'rocketID1'
        expect(online_in_channel[0].username).to eq 'rocketUserName1'
        expect(online_in_channel[1].id).to eq 'rocketID2'
        expect(online_in_channel[1].username).to eq 'rocketUserName2'
      end

      context 'about a missing room' do
        it 'should be nil' do
          expect do
            scope.online(room_id: '1236').to be_nil
            scope.online(name: 'invalid-room').to be_nil
          end
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, roomId: nil) }

      it 'should be failure' do
        expect do
          scope.online(name: 'room-one')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end
end
