module RocketChat
  #
  # Rocket.Chat Info
  #
  class Info
    # Raw info data
    attr_reader :data

    #
    # @param [Hash] data Raw version data
    #
    def initialize(data)
      @data = data.dup.freeze
    end

    # Rocket.Chat version
    def version
      @data['version']
    end

    def inspect
      format(
        '#<%s:0x%p @version="%s">',
        self.class.name,
        object_id,
        version
      )
    end
  end
end
