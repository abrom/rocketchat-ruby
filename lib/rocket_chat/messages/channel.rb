module RocketChat
  module Messages
    #
    # Rocket.Chat Channel messages
    #
    class Channel < Room
      include ListSupport

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
    end
  end
end
