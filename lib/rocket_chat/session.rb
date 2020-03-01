# frozen_string_literal: true

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

    ### Message proxies

    def channels
      @channels ||= RocketChat::Messages::Channel.new(self)
    end

    def groups
      @groups ||= RocketChat::Messages::Group.new(self)
    end

    def users
      @users ||= RocketChat::Messages::User.new(self)
    end

    def chat
      @chat ||= RocketChat::Messages::Chat.new(self)
    end

    def im
      @im ||= RocketChat::Messages::Im.new(self)
    end

    #
    # Settings messages proxy
    # @return [Messages::Settings]
    #
    def settings
      @settings ||= RocketChat::Messages::Settings.new(self)
    end
  end
end
