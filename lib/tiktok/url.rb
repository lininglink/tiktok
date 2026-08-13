# frozen_string_literal: true

module Tiktok
  # Links to pages on tiktok.com, built from a constant host and the pieces that
  # identify the thing — never from a URL some earlier response happened to
  # report. Where a link goes is then decided by this code rather than by data on
  # file, which is what makes it safe to put behind a click.
  module Url
    BASE = "https://www.tiktok.com"

    # A handle's profile page. The handle is normalized on the way in, so an
    # @handle or a profile URL builds the same address a bare handle does.
    def self.profile(handle)
      "#{BASE}/@#{Handle.normalize(handle)}"
    end

    # A single post. TikTok's canonical URL for a video names the account that
    # posted it as well as the video, which is why this wants both.
    def self.video(handle, video_id)
      "#{profile(handle)}/video/#{video_id}"
    end
  end
end
