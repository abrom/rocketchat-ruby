module RocketChat
  module Messages
    #
    # Support methods for *.list calls
    #
    module ListSupport
      def build_list_body(offset, count, sort, fields, query = nil)
        body = {}

        body[:offset] = offset.to_i if offset.is_a? Integer
        body[:count] = count.to_i if count.is_a? Integer
        [[:sort, sort], [:fields, fields], [:query, query]].each do |field, val|
          case val
          when Hash
            body[field] = val.to_json
          when String
            body[field] = val
          end
        end

        body
      end
    end
  end
end
