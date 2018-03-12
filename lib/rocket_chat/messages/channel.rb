module RocketChat
  module Messages
    #
    # Rocket.Chat Channel messages
    #
    class Channel < Room
      include ListSupport

      #
      # channels.join REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def join(room_id: nil, name: nil)
        session.request_json(
          '/api/v1/channels.join',
          method: :post,
          body: room_params(room_id, name)
        )['success']
      end

      #
      # channels.list REST API
      # @param [Integer] offset Query offset
      # @param [Integer] count Query count/limit
      # @param [Hash] sort Query field sort hash. eg `{ msgs: 1, name: -1 }`
      # @param [Hash] fields Query fields to return. eg `{ name: 1, ro: 0 }`
      # @param [Hash] query The query. `{ active: true, type: { '$in': ['name', 'general'] } }`
      # @return [Room[]]
      # @raise [HTTPError, StatusError]
      #
      def list(offset: nil, count: nil, sort: nil, fields: nil, query: nil)
        response = session.request_json(
          '/api/v1/channels.list',
          body: build_list_body(offset, count, sort, fields, query)
        )

        response['channels'].map { |hash| RocketChat::Room.new hash } if response['success']
      end

      #
      # channels.list.joined REST API
      # @param [Integer] offset Query offset
      # @param [Integer] count Query count/limit
      # @param [Hash] sort Query field sort hash. eg `{ msgs: 1, name: -1 }`
      # @param [Hash] fields Query fields to return. eg `{ name: 1, ro: 0 }`
      # @param [Hash] query The query. `{ active: true, type: { '$in': ['name', 'general'] } }`
      # @return [Room[]]
      # @raise [HTTPError, StatusError]
      #
      def list_joined(offset: nil, count: nil, sort: nil, fields: nil, query: nil)
        response = session.request_json(
          '/api/v1/channels.list.joined',
          body: build_list_body(offset, count, sort, fields, query)
        )

        response['channels'].map { |hash| RocketChat::Room.new hash } if response['success']
      end

      # Keys for set_attr:
      # * [String] description A room's description
      # * [String] join_code Code to join a channel
      # * [String] purpose Alias for description
      # * [Boolean] read_only Read-only status
      # * [String] topic A room's topic
      # * [Strong] type c (channel) or p (private group)
      def self.settable_attributes
        %i[description join_code purpose read_only topic type]
      end
    end
  end
end
