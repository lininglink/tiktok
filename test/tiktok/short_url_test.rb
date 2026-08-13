# frozen_string_literal: true

require "test_helper"

module Tiktok
  class ShortUrlTest < Minitest::Test
    SHORT_POST = "https://vm.tiktok.com/ZMabc123/"
    SHORT_SOUND = "https://vt.tiktok.com/ZSabc123/"
    CANONICAL_POST = "https://www.tiktok.com/@bloom.new/video/7529403355681147665"
    CANONICAL_SOUND = "https://www.tiktok.com/music/summer-launch-7529403355681147665"

    # Stands in for the network: a hop table of url => Location header.
    def resolving(hops, url, **options)
      ShortUrl.stub(:location_for, ->(current) { hops[current] }) do
        ShortUrl.resolve(url, **options)
      end
    end

    def test_resolve_follows_a_short_post_link_to_its_canonical_url
      assert_equal CANONICAL_POST,
        resolving({ SHORT_POST => CANONICAL_POST }, SHORT_POST)
    end

    def test_resolve_follows_a_short_sound_link_to_its_canonical_url
      assert_equal CANONICAL_SOUND,
        resolving({ SHORT_SOUND => CANONICAL_SOUND }, SHORT_SOUND)
    end

    def test_resolve_follows_a_chain_of_hops
      hops = {
        SHORT_POST => "https://vt.tiktok.com/ZShop2/",
        "https://vt.tiktok.com/ZShop2/" => CANONICAL_POST
      }

      assert_equal CANONICAL_POST, resolving(hops, SHORT_POST)
    end

    def test_resolve_follows_the_slash_t_form_on_the_canonical_host
      short = "https://www.tiktok.com/t/ZTabc123/"

      assert_equal CANONICAL_POST, resolving({ short => CANONICAL_POST }, short)
    end

    def test_resolve_resolves_a_relative_location_against_the_url_it_came_from
      hops = {
        "https://www.tiktok.com/t/ZTabc123/" => "/@bloom.new/video/7529403355681147665"
      }

      assert_equal CANONICAL_POST, resolving(hops, "https://www.tiktok.com/t/ZTabc123/")
    end

    # Once the handle and the id are in hand there is nothing left to learn, and a
    # further hop could only take them away again.
    def test_resolve_stops_at_the_canonical_url_even_if_it_would_redirect_on
      hops = {
        SHORT_POST => CANONICAL_POST,
        CANONICAL_POST => "https://www.tiktok.com/login"
      }

      assert_equal CANONICAL_POST, resolving(hops, SHORT_POST)
    end

    def test_resolve_stops_at_a_canonical_sound_url_too
      hops = {
        SHORT_SOUND => CANONICAL_SOUND,
        CANONICAL_SOUND => "https://www.tiktok.com/login"
      }

      assert_equal CANONICAL_SOUND, resolving(hops, SHORT_SOUND)
    end

    # A Location header is TikTok telling us where to go, not telling us what to
    # store. One pointing off TikTok stops the walk and keeps the last good URL.
    def test_resolve_refuses_to_follow_a_redirect_off_tiktok
      hops = { SHORT_POST => "https://evil.example.com/phish" }

      assert_equal SHORT_POST, resolving(hops, SHORT_POST)
    end

    def test_resolve_refuses_to_follow_a_redirect_to_a_lookalike_host
      hops = { SHORT_POST => "https://faketiktok.com/@u/video/7529403355681147665" }

      assert_equal SHORT_POST, resolving(hops, SHORT_POST)
    end

    def test_resolve_refuses_to_downgrade_to_http
      hops = { SHORT_POST => "http://www.tiktok.com/@u/video/7529403355681147665" }

      assert_equal SHORT_POST, resolving(hops, SHORT_POST)
    end

    def test_resolve_gives_up_after_max_hops_and_keeps_the_last_url_reached
      last = "https://vm.tiktok.com/hop3/"
      hops = {
        SHORT_POST => "https://vm.tiktok.com/hop2/",
        "https://vm.tiktok.com/hop2/" => last,
        last => "https://vm.tiktok.com/hop4/"
      }

      assert_equal last, resolving(hops, SHORT_POST, max_hops: 2)
    end

    def test_resolve_survives_a_redirect_loop
      hops = {
        SHORT_POST => "https://vm.tiktok.com/ZMloop/",
        "https://vm.tiktok.com/ZMloop/" => SHORT_POST
      }

      assert_includes [ SHORT_POST, "https://vm.tiktok.com/ZMloop/" ], resolving(hops, SHORT_POST)
    end

    def test_resolve_keeps_the_url_when_tiktok_does_not_redirect
      assert_equal SHORT_POST, resolving({}, SHORT_POST)
    end

    def test_resolve_keeps_the_url_when_the_request_blows_up
      blowing_up = ->(_current) { raise Errno::ECONNREFUSED }

      ShortUrl.stub(:location_for, blowing_up) do
        assert_equal SHORT_POST, ShortUrl.resolve(SHORT_POST)
      end
    end

    # The hop tests above stand in for location_for; these are location_for itself,
    # standing in for Net::HTTP.
    class FakeHttp
      attr_accessor :use_ssl, :open_timeout, :read_timeout
      attr_reader :requested

      def initialize(response) = @response = response
      def request(request) = (@requested = request) && @response
    end

    def test_location_for_returns_the_location_of_a_redirect
      http = FakeHttp.new(Net::HTTPFound.new("1.1", "302", "Found").tap { |r|
        r["location"] = CANONICAL_POST
      })

      Net::HTTP.stub(:new, http) do
        assert_equal CANONICAL_POST, ShortUrl.location_for(SHORT_POST)
      end

      assert_kind_of Net::HTTP::Head, http.requested
      assert_equal "/ZMabc123/", http.requested.path
      assert http.use_ssl
    end

    def test_location_for_is_nil_when_the_response_is_not_a_redirect
      http = FakeHttp.new(Net::HTTPOK.new("1.1", "200", "OK"))

      Net::HTTP.stub(:new, http) do
        assert_nil ShortUrl.location_for(SHORT_POST)
      end
    end

    def test_resolve_leaves_a_url_that_is_not_short_alone_without_asking
      exploding = ->(_current) { raise "should not have been called" }

      ShortUrl.stub(:location_for, exploding) do
        assert_equal CANONICAL_POST, ShortUrl.resolve(CANONICAL_POST)
        assert_equal "https://example.com/x", ShortUrl.resolve("https://example.com/x")
        assert_equal "not a url at all", ShortUrl.resolve("not a url at all")
      end
    end
  end
end
