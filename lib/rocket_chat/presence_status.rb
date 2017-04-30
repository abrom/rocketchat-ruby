module RocketChat
  #
  # Rocket.Chat PresenceStatus
  #
  class PresenceStatus
    # Raw presence status data
    attr_reader :data

    #
    # @param [Hash] data Raw presence status data
    #
    def initialize(data)
      @data = Util.stringify_hash_keys data
    end

    # Presence
    def presence
      data['presence']
    end

    # Connection status
    def connection_status
      data['connectionStatus']
    end

    # Last login
    def last_login
      DateTime.parse data['lastLogin']
    rescue
      nil
    end

    def inspect
      format(
        '#<%s:0x%p @presence="%s">',
        self.class.name,
        object_id,
        presence
      )
    end
  end
end
