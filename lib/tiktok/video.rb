# frozen_string_literal: true

module Tiktok
  class Video
    attr_reader :id, :title, :view_count, :like_count, :comment_count, :share_count

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
