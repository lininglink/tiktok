## [Unreleased]

## [0.2.0] - 2026-03-16

- Add `Tiktok::Query` class as the single API client for all TikTok API calls
- `Tiktok::Query#fetch_account` returns a `Tiktok::Account` instance
- `Tiktok::Query#fetch_videos(video_ids)` accepts one or more video IDs and returns an array of `Tiktok::Video` instances
- `Tiktok::Query#refresh_token` refreshes an OAuth token via `Query.new(refresh_token:)`
- `Tiktok::Account` and `Tiktok::Video` are now plain data classes initialized from API response hashes
- Removed API logic from `Account` and `Video` classes

## [0.1.0] - 2026-02-22

- Initial release
