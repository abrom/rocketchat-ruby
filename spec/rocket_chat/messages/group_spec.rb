# frozen_string_literal: true

require 'spec_helper'

describe RocketChat::Messages::Group do
  include_examples 'room_behavior', room_type: 'p', query: false

  describe '#add_leader' do
    before do
      # Stubs for /api/v1/groups.join REST API
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
end
