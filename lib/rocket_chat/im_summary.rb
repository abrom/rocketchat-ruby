module RocketChat
  #
  # Rocket.Chat Info
  #
  class ImSummary
    # Raw info data
    attr_reader :data

    #
    # @param [Hash] data Raw info data
    #
    def initialize(data)
      @data = Util.stringify_hash_keys data
    end

    def joined
      data['joined']
    end

    # Qty of menbers in the chat
    def members
      data['members']
    end

    # Qty of unread messages
    def unreads
      data['unreads']
    end

    # Timestamp
    def unreads_from
      data['unreadsFrom']
    end

    # Qty of messages in the chat
    def msgs
      data['msgs']
    end

    # Last message sent
    def latest
      data['latest']
    end

    # Qty of mentions
    def user_mentions
      data['userMentions']
    end

    def success
      data['success']
    end
  end
end
