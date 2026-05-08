# frozen_string_literal: true

module Tiktok
  class Video
    # Video's unique identifier
    attr_reader :id

    # Video title
    attr_reader :title

    # Video description (caption)
    attr_reader :description

    # URL of the video's cover image (thumbnail)
    attr_reader :cover_image_url

    # Public share URL of the video on tiktok.com
    attr_reader :share_url

    # Embed link for the video
    attr_reader :embed_link

    # Unix timestamp when the video was created
    attr_reader :create_time

    # Video duration in seconds
    attr_reader :duration

    # Number of views
    attr_reader :view_count

    # Number of likes
    attr_reader :like_count

    # Number of comments
    attr_reader :comment_count

    # Number of shares
    attr_reader :share_count

    def initialize(data = {})
      @id = data["id"]
      @title = data["title"]
      @description = data["video_description"]
      @cover_image_url = data["cover_image_url"]
      @share_url = data["share_url"]
      @embed_link = data["embed_link"]
      @create_time = data["create_time"]
      @duration = data["duration"]
      @view_count = data["view_count"]
      @like_count = data["like_count"]
      @comment_count = data["comment_count"]
      @share_count = data["share_count"]
    end
  end
end
