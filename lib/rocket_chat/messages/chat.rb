# frozen_string_literal: true

module RocketChat
  module Messages
    #
    # Rocket.Chat Chat messages
    #
    class Chat
      include RoomSupport

      #
      # @param [Session] session Session
      #
      def initialize(session)
        @session = session
      end

      #
      # chat.delete REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] msg_id The message id to delete
      # @param [Boolean] as_user Message deleted as user who sent (optional - default: false)
      # @return [Boolean]
      # @raise [HTTPError, StatusError]
      #
      def delete(room_id: nil, name: nil, msg_id: nil, as_user: nil)
        session.request_json(
          '/api/v1/chat.delete',
          method: :post,
          body:
            room_params(room_id, name).tap do |h|
              h[:msgId] = msg_id
              h[:asUser] = as_user unless as_user.nil?
            end
        )['success']
      end

      #
      # chat.getMessage REST API
      # @param [String] msg_id The message id to return
      # @return [RocketChat::Message]
      # @raise [HTTPError, StatusError]
      #
      def get_message(msg_id: nil)
        response = session.request_json(
          '/api/v1/chat.getMessage',
          body: { msgId: msg_id }
        )
        RocketChat::Message.new response['message'] if response['success']
      end

      #
      # chat.postMessage REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] channel Rocket.Chat channel name
      # @param [Hash] params Optional params (text, alias, emoji, avatar & attachments)
      # @return [RocketChat::Message]
      # @raise [HTTPError, StatusError]
      #
      def post_message(room_id: nil, name: nil, channel: nil, **params)
        response = session.request_json(
          '/api/v1/chat.postMessage',
          method: :post,
          body: room_params(room_id, name)
            .merge(channel: channel)
            .merge(Util.slice_hash(params, :text, :alias, :emoji, :avatar, :attachments))
        )
        RocketChat::Message.new response['message'] if response['success']
      end

      #
      # chat.update REST API
      # @param [String] room_id Rocket.Chat room id
      # @param [String] name Rocket.Chat room name (coming soon)
      # @param [String] msg_id The message id to update
      # @param [String] text Updated text for the message
      # @return [RocketChat::Message]
      # @raise [HTTPError, StatusError]
      #
      def update(room_id: nil, name: nil, msg_id: nil, text: nil)
        response = session.request_json(
          '/api/v1/chat.update',
          method: :post,
          body: room_params(room_id, name).merge(msgId: msg_id, text: text)
        )
        RocketChat::Message.new response['message'] if response['success']
      end

      private

      attr_reader :session
    end
  end
end
