# frozen_string_literal: true

module RocketChat
  module Messages
    #
    # Rocket.Chat Room messages template (groups&channels)
    #
    class Room # rubocop:disable Metrics/ClassLength
      include RoomSupport
      include UserSupport

      API_PREFIX = '/api/v1'

      def self.inherited(subclass)
        field = subclass.name.split('::')[-1].downcase
        collection = "#{field}s"
        subclass.send(:define_singleton_method, :field) { field }
        subclass.send(:define_singleton_method, :collection) { collection }

        super
      end

      #
      # @param [Session] session Session
      #
      def initialize(session)
        @session = session
      end

      # Full API path to call
      def self.api_path(method)
        "#{API_PREFIX}/#{collection}.#{method}"
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
      # *.addAll REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] active_users_only Add active users only
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def add_all(room_id: nil, name: nil, active_users_only: false)
        session.request_json(
          self.class.api_path('addAll'),
          method: :post,
          body: room_params(room_id, name)
                  .merge(activeUsersOnly: active_users_only)
        )['success']
      end

      #
      # *.add_owner REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Rocket.Chat username
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def add_owner(room_id: nil, name: nil, user_id: nil, username: nil)
        session.request_json(
          self.class.api_path('addOwner'),
          method: :post,
          body: room_params(room_id, name)
            .merge(user_params(user_id, username))
        )['success']
      end

      #
      # *.remove_owner REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Rocket.Chat username
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def remove_owner(room_id: nil, name: nil, user_id: nil, username: nil)
        session.request_json(
          self.class.api_path('removeOwner'),
          method: :post,
          body: room_params(room_id, name)
            .merge(user_params(user_id, username))
        )['success']
      end

      #
      # *.add_moderator REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Rocket.Chat username
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def add_moderator(room_id: nil, name: nil, user_id: nil, username: nil)
        session.request_json(
          self.class.api_path('addModerator'),
          method: :post,
          body: room_params(room_id, name)
            .merge(user_params(user_id, username))
        )['success']
      end

      #
      # *.remove_moderator REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Rocket.Chat username
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def remove_moderator(room_id: nil, name: nil, user_id: nil, username: nil)
        session.request_json(
          self.class.api_path('removeModerator'),
          method: :post,
          body: room_params(room_id, name)
            .merge(user_params(user_id, username))
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
      # @param [String] username Rocket.Chat username
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
      # *.kick REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] user_id Rocket.Chat user id
      # @param [String] username Rocket.Chat username
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def kick(room_id: nil, name: nil, user_id: nil, username: nil)
        session.request_json(
          self.class.api_path('kick'),
          method: :post,
          body: room_params(room_id, name)
            .merge(user_params(user_id, username))
        )['success']
      end

      #
      # *.archive REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def archive(room_id: nil, name: nil)
        session.request_json(
          self.class.api_path('archive'),
          method: :post,
          body: room_params(room_id, name)
        )['success']
      end

      #
      # *.unarchive REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def unarchive(room_id: nil, name: nil)
        session.request_json(
          self.class.api_path('unarchive'),
          method: :post,
          body: room_params(room_id, name)
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
      # @param [String] name Rocket.Chat room name (coming soon)
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

      #
      # *.members* REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name
      # @param [Integer] offset Query offset
      # @param [Integer] count Query count/limit
      # @param [Hash] sort Query field sort hash. eg `{ msgs: 1, name: -1 }`
      # @return [Users[]]
      # @raise [HTTPError, StatusError]
      #
      def members(room_id: nil, name: nil, offset: nil, count: nil, sort: nil)
        response = session.request_json(
          self.class.api_path('members'),
          body: room_params(room_id, name).merge(build_list_body(offset, count, sort, nil, nil))
        )

        response['members'].map { |hash| RocketChat::User.new hash } if response['success']
      end

      #
      # *.upload* REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [File] file that should be uploaded to Rocket.Chat room
      # @param [Hash] rest_params Optional params (msg, description, tmid)
      # @return [RocketChat::Message]
      # @raise [HTTPError, StatusError]
      #
      # https://developer.rocket.chat/reference/api/rest-api/endpoints/rooms-endpoints/upload-file-to-a-room
      def upload_file(room_id:, file:, **rest_params)
        response = session.request_json(
          "#{API_PREFIX}/rooms.upload/#{room_id}",
          method: :post,
          form_data: file_upload_hash(file: file, **rest_params)
        )

        RocketChat::Message.new response['message'] if response['success']
      end

      private

      attr_reader :session

      def room_option_hash(options)
        args = [options, :members, :read_only, :custom_fields, :extra_data]

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

      def file_upload_hash(**params)
        permited_keys_for_file_upload = %i[file msg description tmid]
        hash = Util.slice_hash(params, *permited_keys_for_file_upload)

        # NOTE: https://www.rubydoc.info/github/ruby/ruby/Net/HTTPHeader:set_form
        file_options = params.slice(:filename, :content_type).compact
        hash.map do |key, value|
          next [key, value, file_options] if key == :file && file_options.keys.any?

          [key, value] 
        end
      end
    end
  end
end
