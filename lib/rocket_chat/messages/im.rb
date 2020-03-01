# frozen_string_literal: true

module RocketChat
  module Messages
    #
    # Rocket.Chat Direct messages
    #
    class Im
      #
      # @param [Session] session Session
      #
      def initialize(session)
        @session = session
      end

      #
      # im.create REST API
      # @param [String] username Rocket.Chat username
      # @return [RocketChat::Room]
      # @raise [HTTPError, StatusError]
      #
      def create(username:)
        response = session.request_json(
          '/api/v1/im.create',
          method: :post,
          body: { username: username }
        )
        RocketChat::Room.new response['room']
      end

      #
      # im.counters REST API
      # @param [String] room_id Rocket.Chat roomId
      # @param [String] username Rocket.Chat username
      # @return [RocketChat::ImSummary]
      # @raise [HTTPError, StatusError]
      #
      def counters(room_id:, username: nil)
        response = session.request_json(
          '/api/v1/im.counters',
          body: {
            roomId: room_id,
            username: username
          }
        )
        RocketChat::ImSummary.new response
      end

      private

      attr_reader :session
    end
  end
end
