# frozen_string_literal: true

module Tiktok
  # Follows a shortened TikTok link to the page it stands for.
  #
  # A vm.tiktok.com or vt.tiktok.com link — which is what TikTok's own share sheet
  # hands out, for a sound as readily as for a post — carries no handle, no video
  # id and no music id. The only way to learn what it points at is to ask TikTok,
  # so unlike the rest of this gem's URL handling, this makes a network call.
  #
  # Nothing else here needs an access token, and neither does this: it is a HEAD
  # against a public redirect.
  module ShortUrl
    # A share link can take more than one hop to land on the canonical URL, but a
    # chain longer than this is a loop or a wall, not a redirect.
    MAX_HOPS = 5

    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 5

    # The URL a short link stands for, or the URL as given when it is not a short
    # link, when TikTok will not say, or when anything at all goes wrong. Never
    # raises and never returns nil: a link that cannot be resolved is still the
    # best thing the caller has.
    #
    # Stops the moment it reaches a canonical post or sound URL, before a later
    # hop — a login or consent wall — can strip the handle back off it.
    def self.resolve(url, max_hops: MAX_HOPS)
      return url unless Url.short?(url)

      current = url

      max_hops.times do
        location = location_for(current)
        break if location.nil? || location.empty?

        # Relative redirects resolve against the URL they came from. The result is
        # only followed if it is itself a TikTok URL, so a Location header naming
        # somewhere else cannot decide where this ends up — the last good URL
        # stands instead.
        following = join(current, location)
        break if following.nil? || !Url.tiktok?(following)

        current = following
        break if Url.canonical?(current)
      end

      current
    rescue StandardError
      url
    end

    # The Location header of a single HEAD request, or nil when the response is
    # not a redirect. HEAD because the page body is never wanted — only where it
    # would have come from.
    def self.location_for(url)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = OPEN_TIMEOUT
      http.read_timeout = READ_TIMEOUT

      response = http.request(Net::HTTP::Head.new(uri.request_uri))
      return unless response.is_a?(Net::HTTPRedirection)

      response["location"]
    end

    def self.join(base, location)
      URI.join(base, location).to_s
    rescue StandardError
      nil
    end
    private_class_method :join
  end
end
