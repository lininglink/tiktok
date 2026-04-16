# frozen_string_literal: true

module Tiktok
  class Error < StandardError; end

  class ApiError < Error
    attr_reader :code

    def initialize(message = nil, code: nil)
      super(message)
      @code = code
    end
  end

  class TokenInvalid < ApiError; end

  class TokenExpired < Error; end

  class TransportError < Error; end
end
