# frozen_string_literal: true

module RocketChat
  #
  # Rocket.Chat User
  #
  class User
    # Raw user data
    attr_reader :data

    #
    # @param [Hash] data Raw user data
    #
    def initialize(data)
      @data = Util.stringify_hash_keys data
    end

    # User ID
    def id
      data['_id']
    end

    # User name
    def name
      data['name']
    end

    # User emails
    def emails
      data['emails'] || []
    end

    # User email
    def email
      emails.first && emails.first['address']
    end

    # User email verified
    def email_verified?
      emails.first && emails.first['verified']
    end

    # User status
    def status
      data['status']
    end

    # User connection status
    def status_connection
      data['statusConnection']
    end

    # User username
    def username
      data['username']
    end

    # User UTC offset
    def utc_offset
      data['utcOffset']
    end

    # User active
    def active?
      data['active']
    end

    # User roles
    def roles
      data['roles']
    end

    # User rooms
    def rooms
      return [] unless data['rooms'].is_a? Array

      data['rooms'].map { |hash| RocketChat::Room.new hash }
    end

    def inspect
      format(
        '#<%<class_name>s:0x%<object_id>p @id="%<id>s" @username="%<username>s" @active="%<active>s">',
        class_name: self.class.name,
        object_id: object_id,
        id: id,
        username: username,
        active: active?
      )
    end
  end
end
