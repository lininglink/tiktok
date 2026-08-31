# frozen_string_literal: true

module Tiktok
  # A TikTok sound, as pasted from the page it lives on.
  module Sound
    # The id at the end of a sound's URL. It is the same id a post reports as the
    # music it used, which is what makes it worth pulling out: given a sound and a
    # pile of posts, this is what tells you which of them used it.
    #
    # https://www.tiktok.com/music/some-name-7529403355681147665 ends in the id,
    # and query strings and a trailing slash are both tolerated. A bare id on its
    # own is taken as given.
    MUSIC_ID = /\d{6,}\z/

    # The music id, or nil when the string carries neither a URL ending in one nor
    # an id on its own — in which case there is nothing to match posts against.
    def self.music_id(value)
      value.to_s.split("?").first.to_s.split("/").last.to_s[MUSIC_ID]
    end
  end
end
