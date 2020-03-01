# frozen_string_literal: true

module RocketChat
  module Messages
    #
    # Room params builder for calls with room parameters
    #
    module RoomSupport
      def room_params(id, name)
        if id
          { roomId: id }
        elsif name
          { roomName: name }
        else
          {}
        end
      end
    end
  end
end
