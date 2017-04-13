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

    #
    # me REST API
    # @return [User]
    # @raise [HTTPError, StatusError]
    #
    def me
      response = server.request_json('/api/v1/me', method: :get, token: token, skip_status_check: true)
      raise RocketChat::StatusError, 'Failed to fetch profile' unless response['success']
      User.new response
    end
  end
end
