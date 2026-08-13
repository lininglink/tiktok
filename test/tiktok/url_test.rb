# frozen_string_literal: true

require "test_helper"

module Tiktok
  class UrlTest < Minitest::Test
    def test_profile
      assert_equal "https://www.tiktok.com/@bloom.new", Url.profile("bloom.new")
    end

    def test_profile_normalizes_whatever_form_the_handle_arrives_in
      [ "@Bloom.NEW", " bloom.new ", "https://www.tiktok.com/@Bloom.NEW?lang=en" ].each do |handle|
        assert_equal "https://www.tiktok.com/@bloom.new", Url.profile(handle), "for #{handle}"
      end
    end

    def test_video
      assert_equal "https://www.tiktok.com/@bloom.new/video/7529403355681147665",
        Url.video("bloom.new", "7529403355681147665")
    end

    def test_video_normalizes_the_handle_too
      assert_equal "https://www.tiktok.com/@bloom.new/video/7529403355681147665",
        Url.video("@Bloom.NEW", 7529403355681147665)
    end
  end
end
