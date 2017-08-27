require 'uri'
require 'openssl'
require 'net/http'

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
      upstreamed_errors = Array(options.delete(:upstreamed_errors))

      response = request path, options
      check_response response, fail_unless_ok

      response_json = parse_response(response.body)
      options[:debug].puts("Response: #{response_json.inspect}") if options[:debug]
      check_response_json response_json, upstreamed_errors

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

    def parse_response(response)
      JSON.parse(response)
    rescue JSON::ParserError
      raise RocketChat::JsonParseError, "RocketChat response parse error: #{response}"
    end

    def check_response(response, fail_unless_ok)
      return if response.is_a?(Net::HTTPOK) || !(fail_unless_ok || response.is_a?(Net::HTTPServerError))
      raise RocketChat::HTTPError, "Invalid http response code: #{response.code}"
    end

    def check_response_json(response_json, upstreamed_errors)
      if response_json.key? 'success'
        unless response_json['success'] || upstreamed_errors.include?(response_json['errorType'])
          raise RocketChat::StatusError, response_json['error']
        end
      elsif response_json['status'] != 'success'
        raise RocketChat::StatusError, response_json['message']
      end
    end

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
      http.set_debug_output(options[:debug]) if options[:debug]

      if server.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = options[:ssl_verify_mode]
        http.ca_file = options[:ssl_ca_file] if options[:ssl_ca_file]
      end

      http
    end

    def create_request(path, options)
      headers = get_headers(options)
      body = options[:body]

      if options[:method] == :post
        req = Net::HTTP::Post.new(path, headers)
        add_body(req, body) if body
      else
        uri = path
        uri += '?' + body.map { |k, v| "#{k}=#{v}" }.join('&') if body
        req = Net::HTTP::Get.new(uri, headers)
      end

      req
    end

    def add_body(request, body)
      if body.is_a? Hash
        request.body = body.to_json
        request.content_type = 'application/json'
      else
        request.body = body.to_s
      end
    end
  end
end
