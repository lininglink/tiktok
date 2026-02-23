# frozen_string_literal: true

require "net/http"
require "json"

require_relative "tiktok/version"
require_relative "tiktok/account"

module Tiktok
  class Error < StandardError; end
end
