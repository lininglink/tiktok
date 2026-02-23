# frozen_string_literal: true

require "net/http"
require "json"

require_relative "tiktok/version"
require_relative "tiktok/account"
require_relative "tiktok/video"

module Tiktok
  class Error < StandardError; end
end
