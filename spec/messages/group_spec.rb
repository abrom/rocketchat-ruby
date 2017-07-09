require 'spec_helper'

describe RocketChat::Messages::Group do
  include_examples 'room_behavior', room_type: 'p', query: false

  describe '#add_leader' do
    before do
      # Stubs for /api/v1/channels.join REST API
      stub_request(:post, SERVER_URI + '/api/v1/groups.addLeader')
          .to_return(body: UNAUTHORIZED_BODY, status: 401)

      stub_authed_request(:post, '/api/v1/groups.addLeader')
          .to_return(not_provided_room_body)

      stub_authed_request(:post, '/api/v1/groups.addLeader')
          .with(
              body: { roomId: 'missing-room', leader: '1' }
          ).to_return(invalid_room_body)

      stub_authed_request(:post, '/api/v1/groups.addLeader')
          .with(
              body: { roomId: 'a-room' , leader: '1'}.to_json
          ).to_return(
          body: { success: true }.to_json,
          status: 200
      )
    end

    context 'valid session' do
      # it 'should be success' do
      #   expect(scope.add_leader(room_id: 'a-room', leader: '1')).to be_truthy
      # end

      # context 'about a missing room' do
      #   it 'should raise an error' do
      #     expect do
      #       scope.add_leader(room_id: 'missing-room', leader: '1')
      #     end.to raise_error(
      #                RocketChat::StatusError,
      #                'The required "roomId" or "roomName" param provided does not match any group [error-room-not-found]'
      #            )
      #   end
      # end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, roomId: nil) }

      it 'should be failure' do
        expect do
          scope.add_leader(room_id: 'a-room', leader: 'test')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end


end
