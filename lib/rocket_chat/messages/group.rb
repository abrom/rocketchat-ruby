module RocketChat
  module Messages
    #
    # Rocket.Chat Group messages
    #
    class Group < Room
      include ListSupport

      # groups.list REST API
      # @param [Integer] offset Query offset
      # @param [Integer] count Query count/limit
      # @param [Hash] sort Query field sort hash. eg `{ msgs: 1, name: -1 }`
      # @param [Hash] fields Query fields to return. eg `{ name: 1, ro: 0 }`
      # @return [Room[]]
      # @raise [HTTPError, StatusError]
      #
      def list(offset: nil, count: nil, sort: nil, fields: nil)
        response = session.request_json(
          '/api/v1/groups.list',
          body: build_list_body(offset, count, sort, fields)
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
