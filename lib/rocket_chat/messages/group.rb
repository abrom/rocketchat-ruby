module RocketChat
  module Messages
    #
    # Rocket.Chat Group messages
    #
    class Group < Room
      include ListSupport

      #
      # *.add_leader REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] leader Rocket.Chat user id
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def add_leader(room_id: nil, user_id: nil)
        session.request_json(
          self.class.api_path('addLeader'),
          method: :post,
          body: {
            roomId: room_id,
            userId: user_id
          },
          upstreamed_errors: ['error-room-not-found']
        )['success']
      end

      #
      # *.remove_leader REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] leader Rocket.Chat user id
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def remove_leader(room_id: nil, user_id: nil)
        session.request_json(
          self.class.api_path('removeLeader'),
          method: :post,
          body: {
            roomId: room_id,
            userId: user_id
          },
          upstreamed_errors: ['error-room-not-found']
        )['success']
      end

      # groups.list REST API
      # @param [Integer] offset Query offset
      # @param [Integer] count Query count/limit
      # @param [Hash] sort Query field sort hash. eg `{ msgs: 1, name: -1 }`
      # @param [Hash] fields Query fields to return. eg `{ name: 1, ro: 0 }`
      # @return [Room[]]
      # @raise [HTTPError, StatusError]
      #
      def list(offset: nil, count: nil, sort: nil, fields: nil, query: nil)
        response = session.request_json(
          '/api/v1/groups.list',
          body: build_list_body(offset, count, sort, fields, query)
        )

        response['groups'].map { |hash| RocketChat::Room.new hash } if response['success']
      end

      # Keys for set_attr:
      # * [String] description A room's description
      # * [String] purpose Alias for description
      # * [Boolean] read_only Read-only status
      # * [String] topic A room's topic
      # * [Strong] type c (channel) or p (private group)
      def self.settable_attributes
        %i[description purpose read_only topic type]
      end
    end
  end
end
