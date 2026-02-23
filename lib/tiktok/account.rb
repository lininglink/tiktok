# frozen_string_literal: true

module Tiktok
  class Account
    USER_INFO_URL = "https://open.tiktokapis.com/v2/user/info/"
    TOKEN_URL = "https://open.tiktokapis.com/v2/oauth/token/"

    attr_reader :open_id, :display_name, :username, :bio, :avatar_url,
                :follower_count, :following_count, :likes_count

    def initialize(access_token:)
      @access_token = access_token
    end

    def fetch_user_info
      uri = URI.parse(USER_INFO_URL)
      uri.query = URI.encode_www_form({
        fields: "open_id,avatar_url,avatar_url_100,display_name,username,bio_description,follower_count,following_count,likes_count"
      })

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{@access_token}"
      request["Content-Type"] = "application/json"

      response = http.request(request)
      data = JSON.parse(response.body)

      if data["error"] && data["error"]["code"] != "ok"
        @error = data["error"]
        return self
      end

      user = data["data"]["user"]
      @open_id = user["open_id"]
      @display_name = user["display_name"]
      @username = user["username"]
      @bio = user["bio_description"]
      @avatar_url = user["avatar_url_100"]
      @follower_count = user["follower_count"]
      @following_count = user["following_count"]
      @likes_count = user["likes_count"]
      self
    end

    def error?
      !@error.nil? && !@error.empty?
    end

    def token_invalid?
      @error && @error["code"] == "access_token_invalid"
    end

    def error_message
      @error&.dig("message") || "Unknown error"
    end

    def self.refresh_token(refresh_token)
      uri = URI.parse(TOKEN_URL)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request.set_form_data({
        client_key: ENV["TIKTOK_CLIENT_ID"],
        client_secret: ENV["TIKTOK_CLIENT_SECRET"],
        grant_type: "refresh_token",
        refresh_token: refresh_token
      })

      response = http.request(request)
      data = JSON.parse(response.body)

      if data["access_token"] && !data["access_token"].empty?
        data
      else
        warn "TikTok token refresh failed: #{data}"
        nil
      end
    end
  end
end
