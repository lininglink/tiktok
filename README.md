# Tiktok

This is a Ruby gem can call TikTok API.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add tiktok --github=lininglink/tiktok
```

This gem is not on [rubygems.org](https://rubygems.org). Do not run `gem install tiktok` or `bundle add tiktok` (there is a name of this gem for a different gem)

## Usage

### Calling the API

- `Tiktok::Query` takes access_token.
- `Tiktok::Query#fetch_account` returns a `Tiktok::Account` object.

```rb
query = Tiktok::Query.new(access_token: "act.SmSfTu7...")
account = query.fetch_account
account.display_name
```

### Handles, URLs and sounds

Plain string work on TikTok's own formats. No token and no network call, so these
are usable for accounts that never logged in.

```rb
Tiktok::Handle.normalize("  https://www.tiktok.com/@Bloom.NEW?lang=en  ")
# => "bloom.new"    (a bare handle and "@Bloom.NEW" give the same)

Tiktok::Handle.valid?("bloom.new")   # => true
Tiktok::Handle.valid?("bloom/one")   # => false

Tiktok::Url.profile("bloom.new")
# => "https://www.tiktok.com/@bloom.new"
Tiktok::Url.video("bloom.new", "7529403355681147665")
# => "https://www.tiktok.com/@bloom.new/video/7529403355681147665"

Tiktok::Sound.music_id("https://www.tiktok.com/music/summer-launch-7529403355681147665")
# => "7529403355681147665"
```

In Rails, `Tiktok::Handle::FORMAT` is the anchored regexp behind `valid?`, so it
drops straight into a validation:

```rb
normalizes :account_name, with: ->(name) { Tiktok::Handle.normalize(name) }
validates :account_name, format: { with: Tiktok::Handle::FORMAT, allow_blank: true }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lininglink/tiktok. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/lininglink/tiktok/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tiktok project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lininglink/tiktok/blob/master/CODE_OF_CONDUCT.md).
