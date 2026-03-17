# frozen_string_literal: true

module Tiktok
  class Video
    # Video's unique identifier
    attr_reader :id

    # Video title
    attr_reader :title

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
      @view_count = data["view_count"]
      @like_count = data["like_count"]
      @comment_count = data["comment_count"]
      @share_count = data["share_count"]
    end
  end
end
