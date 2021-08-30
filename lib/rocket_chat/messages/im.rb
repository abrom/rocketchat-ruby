# frozen_string_literal: true

module RocketChat
  module Messages
    #
    # Rocket.Chat Direct messages
    #
    class Im
      include ListSupport

      #
      # @param [Session] session Session
      #
      def initialize(session)
        @session = session
      end

      #
      # im.create REST API
      # @param [String] username Rocket.Chat username
      # @param [String[]] usernames Array of Rocket.Chat usernames
      # @param [Boolean] exclude_self Flag indicating whether the authenticated user should be included in the group
      # @return [RocketChat::Room]
      # @raise [HTTPError, StatusError]
      #
      def create(username: nil, usernames: nil, exclude_self: false)
        params =
          if exclude_self
            { usernames: usernames.join(','), excludeSelf: true }
          elsif usernames
            { usernames: usernames.join(',') }
          else
            { username: username }
          end

        response = session.request_json(
          '/api/v1/im.create',
          method: :post,
          body: params
        )
        RocketChat::Room.new response['room']
      end

      #
      # im.delete REST API
      # @param [String] room_id Rocket.Chat direct message room ID
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def delete(room_id: nil)
        session.request_json(
          '/api/v1/im.delete',
          method: :post,
          body: { roomId: room_id },
          upstreamed_errors: ['error-room-not-found']
        )['success']
      end

      #
      # im.list.everyone REST API
      # @param [Integer] offset Query offset
      # @param [Integer] count Query count/limit
      # @param [Hash] sort Query field sort hash. eg `{ msgs: 1, name: -1 }`
      # @param [Hash] fields Query fields to return. eg `{ name: 1, ro: 0 }`
      # @param [Hash] query The query. `{ active: true, type: { '$in': ['name', 'general'] } }`
      # @return [Room[]]
      # @raise [HTTPError, StatusError]
      #
      def list_everyone(offset: nil, count: nil, sort: nil, fields: nil, query: nil)
        response = session.request_json(
          '/api/v1/im.list.everyone',
          body: build_list_body(offset, count, sort, fields, query)
        )

        response['ims'].map { |hash| RocketChat::Room.new hash } if response['success']
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
