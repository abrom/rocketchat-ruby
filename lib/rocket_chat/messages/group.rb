# frozen_string_literal: true

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
      def add_leader(room_id: nil, name: nil, user_id: nil, username: nil)
        session.request_json(
          self.class.api_path('addLeader'),
          method: :post,
          body: room_params(room_id, name)
            .merge(user_params(user_id, username))
        )['success']
      end

      #
      # *.remove_leader REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] leader Rocket.Chat user id
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def remove_leader(room_id: nil, name: nil, user_id: nil, username: nil)
        session.request_json(
          self.class.api_path('removeLeader'),
          method: :post,
          body: room_params(room_id, name)
            .merge(user_params(user_id, username))
        )['success']
      end

      #
      # groups.kick REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] user_id Rocket.Chat user id
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def kick(room_id: nil, user_id: nil)
        session.request_json(
          '/api/v1/groups.kick',
          method: :post,
          body: room_params(room_id, nil).merge(user_params(user_id, nil))
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

      # groups.listAll REST API
      # @param [Integer] offset Query offset
      # @param [Integer] count Query count/limit
      # @param [Hash] sort Query field sort hash. eg `{ msgs: 1, name: -1 }`
      # @param [Hash] fields Query fields to return. eg `{ name: 1, ro: 0 }`
      # @return [Room[]]
      # @raise [HTTPError, StatusError]
      #
      def list_all(offset: nil, count: nil, sort: nil, fields: nil, query: nil)
        response = session.request_json(
          '/api/v1/groups.listAll',
          body: build_list_body(offset, count, sort, fields, query)
        )

        response['groups'].map { |hash| RocketChat::Room.new hash } if response['success']
      end

      #
      # groups.online REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name
      # @return [Users[]]
      # @note Must provide either `room_id` or `name` parameter. `room_id` will take precedence if providing both
      # @raise [HTTPError, StatusError]
      #
      def online(room_id: nil, name: nil)
        response = session.request_json(
          '/api/v1/groups.online',
          body: { query: room_query_params(room_id, name) }
        )

        response['online'].map { |hash| RocketChat::User.new hash } if response['success']
      end

      # Keys for set_attr:
      # * [String] announcement Announcement for the channel
      # * [Hash] custom_fields Custom fields for the channel
      # * [String] description A room's description
      # * [String] purpose Alias for description
      # * [Boolean] read_only Read-only status
      # * [String] topic A room's topic
      # * [Strong] type c (channel) or p (private group)
      def self.settable_attributes
        %i[announcement custom_fields description purpose read_only topic type]
      end
    end
  end
end
