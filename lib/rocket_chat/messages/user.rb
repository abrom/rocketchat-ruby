# frozen_string_literal: true

module RocketChat
  module Messages
    #
    # Rocket.Chat User messages
    #
    class User
      include ListSupport
      include UserSupport

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
      # users.createToken REST API
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Username
      # @return [RocketChat::Token]
      # @raise [HTTPError, StatusError]
      #
      def create_token(user_id: nil, username: nil)
        response = session.request_json(
          '/api/v1/users.createToken',
          method: :post,
          body: user_params(user_id, username)
        )
        RocketChat::Token.new response['data']
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
      # users.delete REST API
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Username
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def delete(user_id: nil, username: nil)
        session.request_json(
          '/api/v1/users.delete',
          method: :post,
          body: user_params(user_id, username),
          upstreamed_errors: ['error-invalid-user']
        )['success']
      end

      #
      # users.list REST API
      # @param [Integer] offset Query offset
      # @param [Integer] count Query count/limit
      # @param [Hash] sort Query field sort hash. eg `{ active: 1, email: -1 }`
      # @param [Hash] fields Query fields to return. eg `{ name: 1, email: 0 }`
      # @param [Hash] query The query. `{ active: true, type: { '$in': ['user', 'bot'] } }`
      # @return [User[]]
      # @raise [HTTPError, StatusError]
      #
      def list(offset: nil, count: nil, sort: nil, fields: nil, query: nil)
        response = session.request_json(
          '/api/v1/users.list',
          body: build_list_body(offset, count, sort, fields, query)
        )

        response['users'].map { |hash| RocketChat::User.new hash } if response['success']
      end

      #
      # users.info REST API
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Username
      # @return [User]
      # @raise [HTTPError, StatusError]
      #
      def info(user_id: nil, username: nil)
        response = session.request_json(
          '/api/v1/users.info',
          body: user_params(user_id, username),
          upstreamed_errors: ['error-invalid-user']
        )

        RocketChat::User.new response['user'] if response['success']
      end

      #
      # users.getPresence REST API
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Username
      # @return [PresenceStatus]
      # @raise [HTTPError, StatusError]
      #
      def get_presence(user_id: nil, username: nil)
        response = session.request_json(
          '/api/v1/users.getPresence',
          body: user_params(user_id, username)
        )

        RocketChat::PresenceStatus.new response if response['success']
      end

      #
      # users.setAvatar REST API
      # @param [String] avatar_url URL to use for avatar
      # @param [String] user_id user to update (optional)
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def set_avatar(avatar_url, user_id: nil)
        body = { avatarUrl: avatar_url }
        body[:userId] = user_id if user_id
        session.request_json(
          '/api/v1/users.setAvatar',
          method: :post,
          body: body
        )['success']
      end

      #
      # users.resetAvatar REST API
      # @param [String] user_id user to update (optional)
      # @param [String] username Username (optional)
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def reset_avatar(user_id: nil, username: nil)
        session.request_json(
          '/api/v1/users.resetAvatar',
          method: :post,
          body: user_params(user_id, username)
        )['success']
      end

      private

      attr_reader :session

      def user_option_hash(options, include_personal_fields = false)
        args = [options, :active, :roles, :join_default_channels, :require_password_change,
                :send_welcome_email, :verified, :custom_fields]
        args += %i[username email name password] if include_personal_fields

        options = Util.slice_hash(*args)
        return {} if options.empty?

        new_hash = {}
        options.each { |key, value| new_hash[Util.camelize(key)] = value }
        new_hash
      end
    end
  end
end
