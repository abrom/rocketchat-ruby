module RocketChat
  #
  # Rocket.Chat generic utility functions
  #
  module Util
    #
    # Stringify symbolized hash keys
    # @param [Hash] hash A string/symbol keyed hash
    # @return Stringified hash
    #
    def stringify_hash_keys(hash)
      newhash = {}
      hash.each do |key, value|
        newhash[key.to_s] = value
      end
      newhash
    end
    module_function :stringify_hash_keys
  end
end
