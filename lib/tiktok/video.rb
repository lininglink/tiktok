# frozen_string_literal: true

module Tiktok
  class Video
    VIDEO_QUERY_URL = "https://open.tiktokapis.com/v2/video/query/"

    attr_reader :id, :title, :view_count, :like_count, :comment_count, :share_count

    def initialize(access_token:)
      @access_token = access_token
    end

    def fetch_info(video_ids)
      video_ids = Array(video_ids)

      uri = URI.parse(VIDEO_QUERY_URL)
      uri.query = URI.encode_www_form({
        fields: "id,title,view_count,like_count,comment_count,share_count"
      })

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Authorization"] = "Bearer #{@access_token}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate({ filters: { video_ids: video_ids } })

      response = http.request(request)
      data = JSON.parse(response.body)

      if data["error"] && data["error"]["code"] != "ok"
        @error = data["error"]
        return self
      end

      videos = data.dig("data", "videos")
      if videos && videos.any?
        video = videos.first
        @id = video["id"]
        @title = video["title"]
        @view_count = video["view_count"]
        @like_count = video["like_count"]
        @comment_count = video["comment_count"]
        @share_count = video["share_count"]
      end

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
  end
end
