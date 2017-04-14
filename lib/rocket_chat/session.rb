module RocketChat
  #
  # Rocket.Chat Session
  #
  class Session
    # Server
    attr_reader :server
    # Session token
    attr_reader :token

    #
    # @param [Server] server Server
    # @param [Token] token Session token
    #
    def initialize(server, token)
      @server = server
      @token = token.dup.freeze
    end

    def request_json(path, options = {})
      server.request_json path, options.merge(token: token)
    end

    #
    # logout REST API
    # @return [NilClass]
    # @raise [HTTPError, StatusError]
    #
    def logout
      request_json('/api/v1/logout', method: :post)
      nil
    end

    #
    # me REST API
    # @return [User]
    # @raise [HTTPError, StatusError]
    #
    def me
      User.new request_json('/api/v1/me', method: :get)
    end

    #
    # User messages proxy
    # @return [Messages::User]
    #
    def users
      @users ||= RocketChat::Messages::User.new(self)
    end
  end
end
