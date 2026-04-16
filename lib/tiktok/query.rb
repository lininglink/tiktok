# frozen_string_literal: true

module Tiktok
  class Query
    USER_INFO_URL = "https://open.tiktokapis.com/v2/user/info/"
    VIDEO_QUERY_URL = "https://open.tiktokapis.com/v2/video/query/"
    TOKEN_URL = "https://open.tiktokapis.com/v2/oauth/token/"

    def initialize(access_token: nil, refresh_token: nil)
      @access_token = access_token
      @refresh_token = refresh_token
    end

    # Fetches the authenticated user's account.
    # If a refresh_token was provided, transparently retries once after
    # exchanging it for a new access_token on TokenInvalid. The optional
    # block is yielded the new token payload so the caller can persist it.
    def fetch_account(&blk)
      with_refresh(&blk) { do_fetch_account }
    end

    # Fetches videos by id. Same auto-refresh semantics as fetch_account.
    def fetch_videos(video_ids, &blk)
      with_refresh(&blk) { do_fetch_videos(Array(video_ids)) }
    end

    private

    def with_refresh(&blk)
      yield
    rescue TokenInvalid
      raise unless @refresh_token

      token_data = exchange_refresh_token
      raise TokenExpired, "refresh_token exchange failed" unless token_data

      @access_token = token_data["access_token"]
      @refresh_token = token_data["refresh_token"] if token_data["refresh_token"]
      blk&.call(token_data)

      yield
    end

    def do_fetch_account
      uri = URI.parse(USER_INFO_URL)
      uri.query = URI.encode_www_form({
        fields: "open_id,avatar_url,avatar_url_100,display_name,username,bio_description,follower_count,following_count,likes_count"
      })

      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{@access_token}"
      request["Content-Type"] = "application/json"

      data = perform(uri, request)
      check_api_error!(data)
      Account.new(data["data"]["user"])
    end

    def do_fetch_videos(video_ids)
      uri = URI.parse(VIDEO_QUERY_URL)
      uri.query = URI.encode_www_form({
        fields: "id,title,view_count,like_count,comment_count,share_count"
      })

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Authorization"] = "Bearer #{@access_token}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate({ filters: { video_ids: video_ids } })

      data = perform(uri, request)
      check_api_error!(data)
      (data.dig("data", "videos") || []).map { |v| Video.new(v) }
    end

    def exchange_refresh_token
      uri = URI.parse(TOKEN_URL)
      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request.set_form_data({
        client_key: ENV["TIKTOK_CLIENT_ID"],
        client_secret: ENV["TIKTOK_CLIENT_SECRET"],
        grant_type: "refresh_token",
        refresh_token: @refresh_token
      })

      data = perform(uri, request)

      if data["access_token"] && !data["access_token"].empty?
        data
      else
        warn "TikTok token refresh failed: #{data}"
        nil
      end
    end

    def perform(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 10

      response = http.request(request)
      JSON.parse(response.body)
    rescue JSON::ParserError, SocketError, Timeout::Error, Net::HTTPError, Errno::ECONNRESET, Errno::ECONNREFUSED => e
      raise TransportError, e.message
    end

    def check_api_error!(data)
      err = data["error"]
      return unless err && err["code"] && err["code"] != "ok"

      code = err["code"]
      message = err["message"] || "Unknown error"
      raise TokenInvalid.new(message, code: code) if code == "access_token_invalid"

      raise ApiError.new(message, code: code)
    end
  end
end
