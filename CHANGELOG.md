## [Unreleased]

## [0.5.0] - 2026-08-13

- Add `Tiktok::Handle`, `Tiktok::Url` and `Tiktok::Sound` — the grammar of TikTok's own handles and URLs, with no API call behind any of it. Usable without an access token, unlike everything else in the gem.
- `Tiktok::Handle.normalize` turns a bare handle, an `@handle` or a full profile URL into the bare lowercase handle; `Tiktok::Handle.valid?` and `Tiktok::Handle::FORMAT` say whether one could have been issued.
- `Tiktok::Url.profile` and `Tiktok::Url.video` build links from a constant host rather than from a stored URL.
- `Tiktok::Sound.music_id` reads the id off a sound's page URL, which is the id a post reports as the music it used.

## [0.4.0] - 2026-05-08

- Add `Tiktok::Query#revoke!` calling `POST /v2/oauth/revoke/`. Best-effort: returns true on success, false on TikTok-side error or transport failure (does not raise), so callers can safely run it before deleting local OAuth state.

## [0.3.1] - 2026-05-08

- `fetch_account` no longer requests `follower_count`, `following_count`, `likes_count`, or `video_count`. These require the `user.info.stats` scope, and requesting them without that scope causes TikTok to return `scope_not_authorized`. The `Tiktok::Account` accessors are kept so callers that *do* hold `user.info.stats` can still build an `Account` from a response that includes these fields, but the gem no longer requests them automatically.

## [0.3.0] - 2026-05-08

- Add `Tiktok::Query#fetch_my_videos(cursor:, max_count:)` calling `/v2/video/list/`. Returns `{ videos:, cursor:, has_more: }`.
- `Tiktok::Account` now exposes `video_count`, fetched alongside the existing follower/following/like counts in `fetch_account`.
- `Tiktok::Video` now exposes `description`, `cover_image_url`, `share_url`, `embed_link`, `create_time`, and `duration`. `fetch_videos` requests these fields too.

## [0.2.0] - 2026-03-16

- Add `Tiktok::Query` class as the single API client for all TikTok API calls
- `Tiktok::Query#fetch_account` returns a `Tiktok::Account` instance
- `Tiktok::Query#fetch_videos(video_ids)` accepts one or more video IDs and returns an array of `Tiktok::Video` instances
- `Tiktok::Query#refresh_token` refreshes an OAuth token via `Query.new(refresh_token:)`
- `Tiktok::Account` and `Tiktok::Video` are now plain data classes initialized from API response hashes
- Removed API logic from `Account` and `Video` classes

## [0.1.0] - 2026-02-22

- Initial release
