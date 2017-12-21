module RocketChat
  #
  # Rocket.Chat Info
  #
  class Info
    # Raw info data
    attr_reader :data

    #
    # @param [Hash] data Raw info data
    #
    def initialize(data)
      @data = data.dup.freeze
    end

    # Rocket.Chat version
    def version
      data['version']
    end

    def inspect
      format(
        '#<%<class_name>s:0x%<object_id>p @version="%<version>s">',
        class_name: self.class.name,
        object_id: object_id,
        version: version
      )
    end
  end
end
