# frozen_string_literal: true

module Tiktok
  # A TikTok handle, in each of the shapes someone might hand you one.
  #
  # People paste whatever they have to hand — a bare handle, an @handle, or the
  # whole profile URL — and all three name the same account. TikTok's own
  # canonical form is the bare lowercase one, so that is what this normalizes to.
  #
  # No API call is involved: this is the grammar of a handle, not a lookup. A
  # handle that is well formed here may still belong to nobody.
  module Handle
    # What TikTok itself issues, plus hyphens: TikTok's signup rules exclude them,
    # but accounts carried over from Musical.ly have them.
    #
    # Anchored, and deliberately narrow. A handle gets interpolated into URLs and
    # handed to scrapers, so what this has to keep out is anything with meaning in
    # a URL — a slash, colon, quote, space or angle bracket.
    FORMAT = /\A[a-z0-9._-]+\z/

    # The @handle in a profile URL's path, stopping at the next path separator or
    # at a query string or fragment, so ".../@name?lang=en" gives up just "name".
    PROFILE_PATH = %r{/@([^/?#]+)}

    # The bare lowercase handle, whichever of the three forms was given.
    #
    # Nil in, nil out. Anything else comes back a String, well formed or not —
    # normalizing says what was meant, `valid?` says whether it can exist.
    def self.normalize(value)
      return if value.nil?

      handle = value.to_s.strip
      (handle[PROFILE_PATH, 1] || handle.delete_prefix("@")).downcase
    end

    # Whether this could be a handle TikTok issued. Takes the bare form, so
    # normalize first: "@name" and a profile URL are both false here.
    def self.valid?(value)
      FORMAT.match?(value.to_s)
    end
  end
end
