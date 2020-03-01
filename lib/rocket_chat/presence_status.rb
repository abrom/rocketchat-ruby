# frozen_string_literal: true

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
      Time.parse data['lastLogin']
    rescue ArgumentError, TypeError
      nil
    end

    def inspect
      format(
        '#<%<class_name>s:0x%<object_id>p @presence="%<presence>s">',
        class_name: self.class.name,
        object_id: object_id,
        presence: presence
      )
    end
  end
end
