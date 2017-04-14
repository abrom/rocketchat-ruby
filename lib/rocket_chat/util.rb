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
      new_hash = {}
      hash.each { |key, value| new_hash[key.to_s] = value }
      new_hash
    end
    module_function :stringify_hash_keys

    #
    # Slice keys from hash
    # @param [Hash] hash A hash to slice key/value pairs from
    # @param [Array] *keys The keys to be sliced
    # @return Hash filtered by keys
    #
    def slice_hash(hash, *keys)
      return {} if keys.length.zero?

      new_hash = {}
      hash.each do |key, value|
        new_hash[key] = value if keys.include? key
      end
      new_hash
    end
    module_function :slice_hash

    #
    # Camelize a string or symbol
    # @param [String/Symbol] string A string or symbol
    # @return a camelized string
    #
    def camelize(string)
      string.to_s.gsub(/_([a-z])/) { $1.upcase }
    end
    module_function :camelize
  end
end
