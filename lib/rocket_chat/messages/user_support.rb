module RocketChat
  module Messages
    #
    # User params builder for calls with user parameters
    #
    module UserSupport
      def user_params(id, username)
        if id
          { userId: id }
        elsif username
          { username: username }
        end
      end
    end
  end
end
