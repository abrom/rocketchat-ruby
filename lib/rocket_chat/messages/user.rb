module RocketChat
  module Messages
    #
    # Rocket.Chat User messages
    #
    class User
      #
      # @param [Session] session Session
      #
      def initialize(session)
        @session = session
      end

      #
      # users.create REST API
      # @param [String] username Username
      # @param [String] email Email
      # @param [String] name Name
      # @param [String] password Password
      # @param [Hash] options Additional options
      # @return [User]
      # @raise [HTTPError, StatusError]
      #
      def create(username, email, name, password, options = {})
        response = session.request_json(
          '/api/v1/users.create',
          method: :post,
          body: {
            username: username,
            email: email,
            name: name,
            password: password
          }.merge(user_option_hash(options))
        )
        RocketChat::User.new response['user']
      end

      #
      # users.update REST API
      # @param [String] id Rocket.Chat user id
      # @param [Hash] options User properties to update
      # @return [User]
      # @raise [HTTPError, StatusError]
      #
      def update(id, options = {})
        response = session.request_json(
          '/api/v1/users.update',
          method: :post,
          body: {
            userId: id,
            data: user_option_hash(options, true)
          }
        )
        RocketChat::User.new response['user']
      end

      #
      # users.info REST API
      # @param [String] userId Rocket.Chat user id
      # @param [String] username Username
      # @return [User]
      # @raise [HTTPError, StatusError]
      #
      def info(userId: nil, username: nil)
        response = session.request_json(
          '/api/v1/users.info',
          body: userId ? { userId: userId } : { username: username },
          upstreamed_errors: ['error-invalid-user']
        )

        RocketChat::User.new response['user'] if response['success']
      end

      private

      attr_reader :session

      def user_option_hash(options, include_personal_fields = false)
        args = [options, :active, :roles, :join_default_channels, :require_password_change,
                :send_welcome_email, :verified, :custom_fields]
        args += [:username, :email, :name, :password] if include_personal_fields

        options = Util.slice_hash(*args)
        return {} if options.empty?

        new_hash = {}
        options.each { |key, value| new_hash[Util.camelize(key)] = value }
        new_hash
      end
    end
  end
end
