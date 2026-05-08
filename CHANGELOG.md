## [Unreleased]

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
