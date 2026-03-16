# Tiktok

This is a Ruby gem can call TikTok API.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add tiktok --github=lininglink/tiktok
```

This gem is not on [rubygems.org](https://rubygems.org). Do not run `gem install tiktok` or `bundle add tiktok` (there is a name of this gem for a different gem)

## Usage

- `Tiktok::Account` takes access_token.

```rb
account = Tiktok::Account.new(access_token: "act.SmSfTu7...")
account = account.fetch_user_info
account.display_name
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lininglink/tiktok. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/lininglink/tiktok/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tiktok project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/lininglink/tiktok/blob/master/CODE_OF_CONDUCT.md).
