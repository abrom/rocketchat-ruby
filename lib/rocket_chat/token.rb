module RocketChat
  #
  # Rocket.Chat Token
  #
  class Token
    # Raw token data
    attr_reader :data

    #
    # @param [Hash] data Raw token data
    #
    def initialize(data)
      @data = Util.stringify_hash_keys data
    end

    # Authentication token
    def auth_token
      data['authToken']
    end

    # User ID
    def user_id
      data['userId']
    end

    def inspect
      format(
        '#<%<class_name>s:0x%<object_id>p @auth_token="%<auth_token>s", @user_id="%<user_id>s">',
        class_name: self.class.name,
        object_id: object_id,
        auth_token: auth_token,
        user_id: user_id
      )
    end
  end
end
