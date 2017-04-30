module RocketChat
  module Messages
    #
    # Rocket.Chat Settings messages
    #
    class Settings
      #
      # @param [Session] session Session
      #
      def initialize(session)
        @session = session
      end

      #
      # settings get REST API
      # @param [String] id Setting id
      # @return [various]
      # @raise [HTTPError, StatusError]
      #
      def [](id)
        response = session.request_json(
          "/api/v1/settings/#{id}"
        )

        response['value'] if response['success']
      end

      def []=(id, value)
        response = session.request_json(
          "/api/v1/settings/#{id}",
          method: :post,
          body: {
            value: value
          }
        )

        value if response['success']
      end

      private

      attr_reader :session
    end
  end
end
