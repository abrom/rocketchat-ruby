# frozen_string_literal: true

module RocketChat
  #
  # Rocket.Chat Message
  #
  class Message
    # Raw user data
    attr_reader :data

    #
    # @param [Hash] data Raw message data
    #
    def initialize(data)
      @data = Util.stringify_hash_keys data
    end

    # Message ID
    def id
      data['_id']
    end

    # Message thread id
    def tmid
      data['tmid']
    end

    # Timestamp
    def timestamp
      Time.parse data['ts']
    end

    # Updated at
    def updated_at
      Time.parse data['_updatedAt']
    end

    # Room ID
    def room_id
      data['rid']
    end

    # User
    def user
      User.new data['u']
    end

    # Message
    def message
      data['msg']
    end

    # Alias
    def alias
      data['alias']
    end

    # Parse URLs
    def parse_urls
      data['parseUrls']
    end

    # Groupable
    def groupable
      data['groupable']
    end

    def inspect
      format(
        '#<%<class_name>s:0x%<object_id>p @id="%<id>s" @room="%<room_id>s" @msg="%<message>s">',
        class_name: self.class.name,
        object_id: object_id,
        id: id,
        room_id: room_id,
        message: message,
        tmid: tmid
      )
    end
  end
end
