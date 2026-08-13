# frozen_string_literal: true

module Tiktok
  # Links to pages on tiktok.com: building them, and reading them back apart.
  #
  # Everything here is string work — nothing in this module makes a network call.
  # Following a shortened link to the page it stands for does, and lives in
  # Tiktok::ShortUrl.
  module Url
    BASE = "https://www.tiktok.com"

    # Where a shared link points before it has been followed. TikTok mints these
    # from the share sheet, for sounds as readily as for posts, and they carry
    # neither the handle nor any id — only the redirect knows what they stand for.
    SHORT_HOSTS = %w[vm.tiktok.com vt.tiktok.com].freeze

    # The other shape a share link takes: the canonical host with an opaque token
    # under /t/, e.g. https://www.tiktok.com/t/ZTabc123/.
    SHORT_PATH = %r{\A/t/}

    # Both are videos as far as anything here is concerned; TikTok routes image
    # slideshows under /photo/ and everything else under /video/.
    VIDEO_PATH = %r{/(?:video|photo)/(\d+)}

    MUSIC_PATH = %r{/music/}

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

    # The URL with its query string and fragment dropped.
    #
    # Worth doing to anything ShortUrl.resolve hands back: TikTok answers a share
    # link with the canonical URL followed by a long query naming the account that
    # shared it — sec_user_id, user_id, a checksum, the device it was shared from.
    # None of that says anything about the sound or the post, and it does not
    # belong in a stored URL or on a page. Anything unparseable comes back as it
    # went in.
    def self.without_query(url)
      uri = URI.parse(url.to_s)
      uri.query = nil
      uri.fragment = nil
      uri.to_s
    rescue URI::InvalidURIError
      url
    end

    # True only for https URLs on tiktok.com or a subdomain of it.
    #
    # The host is compared whole, not by suffix: "faketiktok.com" ends in
    # "tiktok.com" as a string, and "tiktok.com.example.com" begins with it, and
    # neither is TikTok. This is the gate everything else here goes through, so a
    # URL that fails it is never parsed, followed or trusted.
    def self.tiktok?(url)
      uri = URI.parse(url.to_s)
      return false unless uri.scheme == "https"

      host = uri.host&.downcase
      host == "tiktok.com" || host&.end_with?(".tiktok.com") || false
    rescue URI::InvalidURIError
      false
    end

    # A shortened link — one that has to be followed before it says anything.
    def self.short?(url)
      return false unless tiktok?(url)

      uri = URI.parse(url.to_s)
      SHORT_HOSTS.include?(uri.host&.downcase) || uri.path.to_s.match?(SHORT_PATH)
    rescue URI::InvalidURIError
      false
    end

    # The video id in a post URL, or nil if there isn't one.
    def self.video_id(url)
      return unless tiktok?(url)

      url[VIDEO_PATH, 1]
    end

    # The bare lowercase handle in a URL, or nil if there isn't one.
    def self.handle(url)
      return unless tiktok?(url)

      Handle.normalize(url[Handle::PROFILE_PATH, 1])
    end

    # The music id in a sound URL, or nil if there isn't one. Unlike
    # Sound.music_id this wants a real TikTok URL — a bare id is not one.
    def self.music_id(url)
      return unless tiktok?(url) && URI.parse(url.to_s).path.to_s.match?(MUSIC_PATH)

      Sound.music_id(url)
    rescue URI::InvalidURIError
      nil
    end

    # A post URL that names both the account and the video — everything a caller
    # needs, and the form a short link is being followed to reach.
    def self.canonical_video?(url)
      !video_id(url).nil? && !handle(url).nil?
    end

    # A sound URL that carries its id, which is the whole reason to have one.
    def self.canonical_music?(url)
      !music_id(url).nil?
    end

    # Either of the two above: there is nothing further to be learned by
    # following this link again.
    def self.canonical?(url)
      canonical_video?(url) || canonical_music?(url)
    end
  end
end
