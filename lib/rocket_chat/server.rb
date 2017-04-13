module RocketChat
  #
  # Rocket.Chat Server
  #
  class Server
    include RocketChat::RequestHelper

    # Server options
    attr_reader :options

    #
    # @param [URI, String] server Server URI
    # @param [Hash] options Server options
    #
    def initialize(server, options = {})
      self.server = server
      @options = options
    end

    #
    # Info REST API
    # @return [Info] Rocket.Chat Info
    # @raise [HTTPError, StatusError]
    #
    def info
      response = request_json '/api/v1/info', fail_unless_ok: true
      Info.new response['info']
    end

    #
    # Login REST API
    # @param [String] username Username
    # @param [String] password Password
    # @return [Session] Rocket.Chat Session
    # @raise [HTTPError, StatusError]
    #
    def login(username, password)
      response = request_json(
        '/api/v1/login',
        method: :post,
        body: {
          username: username,
          password: password
        }
      )
      Session.new self, Token.new(response['data'])
    end
  end
end
