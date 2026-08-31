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

Reading a URL back apart:

```rb
Tiktok::Url.video_id("https://www.tiktok.com/@bloom.new/video/7529403355681147665")
# => "7529403355681147665"
Tiktok::Url.handle("https://www.tiktok.com/@Bloom.NEW/video/7529403355681147665")
# => "bloom.new"
Tiktok::Url.music_id("https://www.tiktok.com/music/summer-launch-7529403355681147665")
# => "7529403355681147665"

Tiktok::Url.tiktok?("https://faketiktok.com/x")   # => false (host compared whole)
Tiktok::Url.short?("https://vm.tiktok.com/ZM123/")  # => true
```

### Shortened links

TikTok's share sheet hands out `vm.tiktok.com` / `vt.tiktok.com` links — for
sounds as readily as for posts — and they carry no handle and no id. Following one
is the only way to find out what it stands for, so this method, alone in the gem's
URL handling, makes a network call (a HEAD; no token needed).

```rb
Tiktok::ShortUrl.resolve("https://vm.tiktok.com/ZMabc123/")
# => "https://www.tiktok.com/@bloom.new/video/7529403355681147665"

Tiktok::ShortUrl.resolve("https://vt.tiktok.com/ZSabc123/")
# => "https://www.tiktok.com/music/summer-launch-7529403355681147665"
```

It follows at most 5 hops and stops as soon as the URL names what it points at, so
a later login wall cannot strip the handle back off. A `Location` header leaving
tiktok.com or dropping to http is not followed. Anything that goes wrong — a
timeout, a refused connection, a URL that was never short — gives back the URL as
passed in, never nil and never an exception.

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
