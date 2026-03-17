# frozen_string_literal: true

module Tiktok
  class Account
    # TikTok user's unique identifier
    attr_reader :open_id

    # User's display name
    attr_reader :display_name

    # User's unique username
    attr_reader :username

    # User's bio description
    attr_reader :bio

    # URL of the user's avatar image
    attr_reader :avatar_url

    # Number of followers
    attr_reader :follower_count

    # Number of accounts the user follows
    attr_reader :following_count

    # Total number of likes received
    attr_reader :likes_count

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
