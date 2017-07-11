module RocketChat
  module Messages
    #
    # Rocket.Chat Room messages template (groups&channels)
    #
    class Room # rubocop:disable Metrics/ClassLength
      include UserSupport

      def self.inherited(subclass)
        field = subclass.name.split('::')[-1].downcase
        collection = field + 's'
        subclass.send(:define_singleton_method, :field) { field }
        subclass.send(:define_singleton_method, :collection) { collection }
      end

      #
      # @param [Session] session Session
      #
      def initialize(session)
        @session = session
      end

      # Full API path to call
      def self.api_path(method)
        "/api/v1/#{collection}.#{method}"
      end

      #
      # *.create REST API
      # @param [String] name Room name
      # @param [Hash] options Additional options
      # @return [Room]
      # @raise [HTTPError, StatusError]
      #
      def create(name, options = {})
        response = session.request_json(
          self.class.api_path('create'),
          method: :post,
          body: {
            name: name
          }.merge(room_option_hash(options))
        )
        RocketChat::Room.new response[self.class.field]
      end

      #
      # *.delete REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def delete(room_id: nil, name: nil)
        session.request_json(
          self.class.api_path('delete'),
          method: :post,
          body: room_params(room_id, name),
          upstreamed_errors: ['error-room-not-found']
        )['success']
      end

      #
      # *.add_owner REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] user_id Rocket.Chat user id
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def add_owner(room_id: nil, user_id: nil)
        session.request_json(
          self.class.api_path('addOwner'),
          method: :post,
          body: {
            roomId: room_id,
            userId: user_id
          },
          upstreamed_errors: ['error-room-not-found']
        )['success']
      end

      #
      # *.remove_owner REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] user_id Rocket.Chat user id
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def remove_owner(room_id: nil, user_id: nil)
        session.request_json(
          self.class.api_path('removeOwner'),
          method: :post,
          body: {
            roomId: room_id,
            userId: user_id
          },
          upstreamed_errors: ['error-room-not-found']
        )['success']
      end

      #
      # *.info REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Room name (channels since 0.56)
      # @return [Room]
      # @raise [HTTPError, StatusError]
      #
      def info(room_id: nil, name: nil)
        response = session.request_json(
          self.class.api_path('info'),
          body: room_params(room_id, name),
          upstreamed_errors: ['error-room-not-found']
        )

        RocketChat::Room.new response[self.class.field] if response['success']
      end

      #
      # *.invite REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Username
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def invite(room_id: nil, name: nil, user_id: nil, username: nil)
        session.request_json(
          self.class.api_path('invite'),
          method: :post,
          body: room_params(room_id, name)
            .merge(user_params(user_id, username))
        )['success']
      end

      #
      # *.leave REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def leave(room_id: nil, name: nil)
        session.request_json(
          self.class.api_path('leave'),
          method: :post,
          body: room_params(room_id, name)
        )['success']
      end

      #
      # *.rename REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] new_name New room name
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def rename(room_id, new_name)
        session.request_json(
          self.class.api_path('rename'),
          method: :post,
          body: { roomId: room_id, name: new_name }
        )['success']
      end

      #
      # *.set* REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] new_name New room name
      # @param [Hash] setting Single key-value
      # @return [Boolean]
      # @raise [ArgumentError, HTTPError, StatusError]
      #
      def set_attr(room_id: nil, name: nil, **setting)
        attribute, value = setting.first
        validate_attribute(attribute)
        session.request_json(
          self.class.api_path(Util.camelize("set_#{attribute}")),
          method: :post,
          body: room_params(room_id, name)
            .merge(Util.camelize(attribute) => value)
        )['success']
      end

      private

      attr_reader :session

      def room_params(id, name)
        if id
          { roomId: id }
        elsif name
          { roomName: name }
        else
          {}
        end
      end

      def room_option_hash(options)
        args = [options, :members, :read_only, :custom_fields]

        options = Util.slice_hash(*args)
        return {} if options.empty?

        new_hash = {}
        options.each { |key, value| new_hash[Util.camelize(key)] = value }
        new_hash
      end

      def validate_attribute(attribute)
        raise ArgumentError, "Unsettable attribute: #{attribute || 'nil'}" unless \
          self.class.settable_attributes.include?(attribute)
      end
    end
  end
end
