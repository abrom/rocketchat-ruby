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

    #
    # logout REST API
    # @return [NilClass]
    # @raise [HTTPError, StatusError]
    #
    def logout
      server.request_json('/api/v1/logout', method: :post, token: token)
      nil
    end
  end
end
