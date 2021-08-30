# frozen_string_literal: true

module RocketChat
  class Error < StandardError; end

  class HTTPError < Error; end

  class InvalidMethodError < HTTPError; end

  class JsonParseError < Error; end

  class StatusError < Error; end
end
