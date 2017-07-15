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

    # Timestamp
    def timestamp
      DateTime.parse data['ts']
    end

    # Updated at
    def updated_at
      DateTime.parse data['_updatedAt']
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
        '#<%s:0x%p @id="%s" @room="%s" @msg="%s">',
        self.class.name,
        object_id,
        id,
        room_id,
        message
      )
    end
  end
end
