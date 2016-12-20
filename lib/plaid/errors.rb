module Plaid
  class PlaidError < StandardError
    attr_reader :code
    attr_reader :resolve
    attr_reader :request_id

    def initialize(code, message, resolve, request_id)
      super(message)
      @code = code
      @resolve = resolve
      @request_id = request_id
    end
  end

  class BadRequest < PlaidError
  end

  class Unauthorized < PlaidError
  end

  class RequestFailed < PlaidError
  end

  class NotFound < PlaidError
  end

  class ServerError < PlaidError
  end
end
