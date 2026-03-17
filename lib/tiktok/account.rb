# frozen_string_literal: true

module Tiktok
  class Account
    attr_reader :open_id, :display_name, :username, :bio, :avatar_url,
                :follower_count, :following_count, :likes_count

    def initialize(data = {})
      @open_id = data["open_id"]
      @display_name = data["display_name"]
      @username = data["username"]
      @bio = data["bio_description"]
      @avatar_url = data["avatar_url_100"]
      @follower_count = data["follower_count"]
      @following_count = data["following_count"]
      @likes_count = data["likes_count"]
    end
  end
end
