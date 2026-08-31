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

    def test_without_query_drops_the_share_tokens_tiktok_answers_with
      resolved = "https://www.tiktok.com/music/Slowed-7660733636526934017" \
        "?_r=1&sec_user_id=MS4wLjABAAAA&share_music_id=7660733636526934017&user_id=7642096780553077768"

      assert_equal "https://www.tiktok.com/music/Slowed-7660733636526934017",
        Url.without_query(resolved)
    end

    def test_without_query_drops_a_fragment_too
      assert_equal "https://www.tiktok.com/@bloom.new",
        Url.without_query("https://www.tiktok.com/@bloom.new#top")
    end

    def test_without_query_leaves_a_url_that_has_none_alone
      [
        "https://www.tiktok.com/@bloom.new/video/7529403355681147665",
        "7529403355681147665",
        ""
      ].each { |url| assert_equal url, Url.without_query(url), "for #{url.inspect}" }
    end

    def test_without_query_hands_junk_back_rather_than_raising
      assert_equal "http://[bad", Url.without_query("http://[bad")
    end

    def test_tiktok_accepts_tiktok_com_and_its_subdomains_over_https
      %w[
        https://www.tiktok.com/x
        https://tiktok.com/x
        https://vm.tiktok.com/x
        https://vt.tiktok.com/x
      ].each { |url| assert Url.tiktok?(url), "for #{url}" }
    end

    # "faketiktok.com" ends in the string, "tiktok.com.attacker.com" starts with
    # it, and neither is TikTok.
    def test_tiktok_rejects_lookalike_hosts
      %w[
        https://faketiktok.com/x
        https://tiktok.com.attacker.com/x
        https://example.com/tiktok.com
      ].each { |url| refute Url.tiktok?(url), "for #{url}" }
    end

    def test_tiktok_rejects_anything_not_https
      refute Url.tiktok?("http://www.tiktok.com/x")
      refute Url.tiktok?("javascript:alert(1);//tiktok.com/video/7529403355681147665")
    end

    def test_tiktok_does_not_raise_on_junk
      refute Url.tiktok?("http://[bad")
      refute Url.tiktok?("not a url at all")
      refute Url.tiktok?(nil)
    end

    def test_short_recognizes_the_share_sheet_forms
      %w[
        https://vm.tiktok.com/ZMabc123/
        https://vt.tiktok.com/ZSabc123/
        https://www.tiktok.com/t/ZTabc123/
      ].each { |url| assert Url.short?(url), "for #{url}" }
    end

    def test_short_is_false_for_a_url_that_already_says_what_it_is
      [
        "https://www.tiktok.com/@bloom.new/video/7529403355681147665",
        "https://www.tiktok.com/music/summer-launch-7529403355681147665",
        "https://www.tiktok.com/@bloom.new",
        "https://faketiktok.com/t/ZTabc123/",
        "not a url at all"
      ].each { |url| refute Url.short?(url), "for #{url}" }
    end

    def test_video_id
      {
        "https://www.tiktok.com/@bloom.new/video/7529403355681147665" => "7529403355681147665",
        "https://tiktok.com/@bloom.new/video/7529403355681147665" => "7529403355681147665",
        "https://www.tiktok.com/@bloom.new/video/7529403355681147665?is_from_webapp=1" => "7529403355681147665",
        "https://www.tiktok.com/@bloom.new/photo/7529403355681147665" => "7529403355681147665"
      }.each { |url, id| assert_equal id, Url.video_id(url), "for #{url}" }
    end

    def test_video_id_is_nil_when_there_is_no_video_in_the_url
      [
        "https://www.tiktok.com/@bloom.new",
        "https://faketiktok.com/@u/video/7529403355681147665",
        "http://www.tiktok.com/@u/video/7529403355681147665",
        "https://example.com",
        nil
      ].each { |url| assert_nil Url.video_id(url), "for #{url.inspect}" }
    end

    def test_handle_reads_the_account_out_of_a_url
      assert_equal "bloom.new", Url.handle("https://www.tiktok.com/@Bloom.NEW/video/7529403355681147665")
      assert_equal "bloom.new", Url.handle("https://www.tiktok.com/@bloom.new?lang=en")
    end

    def test_handle_is_nil_when_the_url_names_no_account
      [
        "https://www.tiktok.com/video/7529403355681147665",
        "https://faketiktok.com/@u/video/7529403355681147665",
        nil
      ].each { |url| assert_nil Url.handle(url), "for #{url.inspect}" }
    end

    # Sound.music_id takes a bare id as given; this wants a real sound URL.
    def test_music_id_wants_a_sound_url
      assert_equal "7529403355681147665",
        Url.music_id("https://www.tiktok.com/music/summer-launch-7529403355681147665")
      assert_nil Url.music_id("7529403355681147665")
      assert_nil Url.music_id("https://www.tiktok.com/@bloom.new/video/7529403355681147665")
      assert_nil Url.music_id("https://faketiktok.com/music/summer-launch-7529403355681147665")
    end

    def test_canonical_is_true_only_once_a_url_says_what_it_points_at
      assert Url.canonical?("https://www.tiktok.com/@bloom.new/video/7529403355681147665")
      assert Url.canonical?("https://www.tiktok.com/music/summer-launch-7529403355681147665")

      refute Url.canonical?("https://vm.tiktok.com/ZMabc123/")
      refute Url.canonical?("https://www.tiktok.com/@bloom.new")
      refute Url.canonical?("https://www.tiktok.com/video/7529403355681147665")
      refute Url.canonical?("https://www.tiktok.com/login")
    end
  end
end
