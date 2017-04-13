module RocketChat
  #
  # Rocket.Chat HTTP request helper
  #
  module RequestHelper
    DEFAULT_REQUEST_OPTIONS = {
      method: :get,
      body: nil,
      headers: nil,
      ssl_verify_mode: OpenSSL::SSL::VERIFY_PEER,
      ssl_ca_file: nil
    }.freeze

    # Server URI
    attr_reader :server

    def server=(server)
      @server = server.is_a?(URI) ? server : URI.parse(server.to_s)
    end

    def request_json(path, options = {})
      fail_unless_ok = options.delete :fail_unless_ok
      response = request path, options

      if fail_unless_ok && !response.is_a?(Net::HTTPOK)
        raise RocketChat::HTTPError, "Invalid http response code: #{response.code}"
      end

      response_json = JSON.parse(response.body)
      unless response_json['status'] == 'success'
        raise RocketChat::StatusError, response_json['message']
      end

      response_json
    end

    def request(path, options = {})
      options = DEFAULT_REQUEST_OPTIONS.merge(options)

      raise RocketChat::InvalidMethodError unless %i[get post].include? options[:method]

      http = create_http(options)
      req = create_request(path, options)
      http.start { http.request(req) }
    end

    private

    def get_headers(options)
      headers = options[:headers]

      token = options.delete :token
      if token
        headers ||= {}

        headers['X-Auth-Token'] = token.auth_token
        headers['X-User-Id'] = token.user_id
      end

      return unless headers
      headers = Util.stringify_hash_keys headers
      headers.delete_if { |key, value| key.nil? || value.nil? }
    end

    def create_http(options)
      http = Net::HTTP.new(server.host, server.port)

      if server.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = options[:ssl_verify_mode]
        http.ca_file = options[:ssl_ca_file] if options[:ssl_ca_file]
      end

      http
    end

    def create_request(path, options)
      headers = get_headers(options)

      req = Net::HTTP.const_get(options[:method].to_s.capitalize).new(path, headers)

      body = options[:body]
      req.body = url_encode(body) unless body.nil?

      req
    end

    def url_encode(body)
      if body.is_a?(Hash)
        body.map do |key, value|
          "#{URI.escape(key.to_s)}=#{URI.escape(value.to_s)}"
        end.join('&')
      else
        body.to_s
      end
    end
  end
end
