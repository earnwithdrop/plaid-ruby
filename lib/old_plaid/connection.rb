require 'net/http'
require 'json'
require 'uri'

module OldPlaid
  class Connection
    class << self
      # API: semi-private
      def post(path, options = {})
        uri = build_uri(path)
        options.merge!(client_id: OldPlaid.customer_id, secret: OldPlaid.secret)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 240
        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data(options)
        res = http.request(request)
        parse_response(res)
      end

      # API: semi-private
      def get(path, id = nil, **options)
        uri = build_uri(path, id)
        uri.query = URI.encode_www_form(options) if options
        request = Net::HTTP::Get.new(uri)
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 240) { |http| http.request(request) }
        parse_get_response(res.body)
      end

      # API: semi-private
      def secure_get(path, access_token, options = {})
        uri = build_uri(path)
        options.merge!({access_token:access_token})
        req = Net::HTTP::Get.new(uri.path)
        req.body = URI.encode_www_form(options) if options
        req.content_type = 'application/x-www-form-urlencoded'
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 240) { |http| http.request(req) }
        parse_response(res)
      end

      # API: semi-private
      def patch(path, options = {})
        uri = build_uri(path)
        options.merge!(client_id: OldPlaid.customer_id, secret: OldPlaid.secret)
        req = Net::HTTP::Patch.new(uri.path)
        req.body = URI.encode_www_form(options) if options
        req.content_type = 'application/x-www-form-urlencoded'
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 240) { |http| http.request(req) }
        parse_response(res)
      end

      # API: semi-private
      def delete(path, options = {})
        uri = build_uri(path)
        options.merge!(client_id: OldPlaid.customer_id, secret: OldPlaid.secret)
        req = Net::HTTP::Delete.new(uri.path)
        req.body = URI.encode_www_form(options) if options
        req.content_type = 'application/x-www-form-urlencoded'
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 240) { |http| http.request(req) }
      end

      protected

      # API: semi-private
      def build_uri(path, option = nil)
        path = path + '/' + option unless option.nil?
        URI.parse(OldPlaid.environment_location + path)
      end

      private

      def parse_response(res)
        # unfortunately, the JSON gem will raise an exception if the response is empty
        raise OldPlaid::ServerError.new(res.code, res.msg, '', res['X-Request-Id']) if res.body.to_s.length < 2
        # we got a response from the server, so parse it
        body = JSON.parse(res.body)
        case res.code.delete('.').to_i
        when 200 then body
        when 201 then { msg: 'Requires further authentication', body: body}
        when 400
          raise OldPlaid::BadRequest.new(body['code'], body['message'], body['resolve'], res['X-Request-Id'])
        when 401
          raise OldPlaid::Unauthorized.new(body['code'], body['message'], body['resolve'], res['X-Request-Id'])
        when 402
          raise OldPlaid::RequestFailed.new(body['code'], body['message'], body['resolve'], res['X-Request-Id'])
        when 404
          raise OldPlaid::NotFound.new(body['code'], body['message'], body['resolve'], res['X-Request-Id'])
        else
          raise OldPlaid::ServerError.new(body['code'], body['message'], body['resolve'], res['X-Request-Id'])
        end
      end

      def parse_get_response(res)
        body = JSON.parse(res)
        return body if body.kind_of?(Array)

        case body['code']
        when nil
          body
        when 1301, 1401, 1501, 1601
          raise OldPlaid::NotFound.new(body['code'], body['message'], body['resolve'], res['X-Request-Id'])
        else
          body
        end
      end

    end
  end
end