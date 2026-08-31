# frozen_string_literal: true

require "test_helper"

module Tiktok
  class SoundTest < Minitest::Test
    def test_music_id_reads_the_id_off_whatever_form_was_pasted
      {
        "https://www.tiktok.com/music/summer-launch-7529403355681147665" => "7529403355681147665",
        "https://www.tiktok.com/music/summer-launch-7529403355681147665?lang=en" => "7529403355681147665",
        "https://www.tiktok.com/music/original-sound-7529403355681147665/" => "7529403355681147665",
        "7529403355681147665" => "7529403355681147665"
      }.each do |sound, music_id|
        assert_equal music_id, Sound.music_id(sound), "for #{sound}"
      end
    end

    def test_music_id_is_nil_when_the_sound_carries_no_id
      [ "summer-launch-sound", "https://www.tiktok.com/music/summer-launch", "", nil ].each do |sound|
        assert_nil Sound.music_id(sound), "for #{sound.inspect}"
      end
    end

    # Short enough to be a year or a track number rather than an id.
    def test_music_id_ignores_a_number_too_short_to_be_one
      assert_nil Sound.music_id("https://www.tiktok.com/music/summer-2026")
    end
  end
end
