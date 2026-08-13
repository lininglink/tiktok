# frozen_string_literal: true

require "test_helper"

module Tiktok
  class HandleTest < Minitest::Test
    def test_normalize_drops_the_at_and_the_case
      assert_equal "bloom.new", Handle.normalize("@Bloom.NEW")
      assert_equal "bloom.new", Handle.normalize("Bloom.NEW")
    end

    def test_normalize_ignores_surrounding_whitespace
      assert_equal "bloom.new", Handle.normalize("  @Bloom.NEW  ")
    end

    def test_normalize_takes_the_handle_out_of_a_profile_url
      {
        "https://www.tiktok.com/@Bloom.URL" => "bloom.url",
        "https://www.tiktok.com/@Bloom.URL?lang=en" => "bloom.url",
        "https://www.tiktok.com/@bloom.url/video/7529403355681147665" => "bloom.url",
        "www.tiktok.com/@bloom.url" => "bloom.url"
      }.each do |given, expected|
        assert_equal expected, Handle.normalize(given), "for #{given}"
      end
    end

    def test_normalize_is_idempotent
      once = Handle.normalize("https://www.tiktok.com/@Bloom.URL?lang=en")

      assert_equal once, Handle.normalize(once)
    end

    def test_normalize_passes_nil_through
      assert_nil Handle.normalize(nil)
    end

    # Normalizing says what was meant; it does not vouch for the result.
    def test_normalize_hands_back_junk_it_cannot_make_sense_of
      assert_equal "bloom one", Handle.normalize("Bloom One")
    end

    def test_valid_accepts_letters_numbers_periods_underscores_and_hyphens
      %w[bloom_1.official kang-kyu bloom1].each do |handle|
        assert Handle.valid?(handle), "#{handle.inspect} should be accepted"
      end
    end

    def test_valid_rejects_anything_with_meaning_in_a_url
      [ "bloom one", "bloom/one", "bloom@one", "bloom<one>", "javascript:alert(1)" ].each do |handle|
        refute Handle.valid?(handle), "#{handle.inspect} should be rejected"
      end
    end

    # It takes the bare form, which is what normalize produces.
    def test_valid_rejects_the_unnormalized_forms
      refute Handle.valid?("@bloom.new")
      refute Handle.valid?("https://www.tiktok.com/@bloom.new")
      refute Handle.valid?("Bloom.NEW")
    end

    def test_valid_rejects_nothing_at_all
      refute Handle.valid?("")
      refute Handle.valid?(nil)
    end
  end
end
