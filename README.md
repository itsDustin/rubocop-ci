# Rubocop for CI

Run rubocop on your CI. Also runs scss-lint now. And coffeelint. And slim-lint.

## Usage

Run `bundle exec rake rubocop` before committing.
Do not use the plain `rubocop` binary, since that will not use the central
configuration file from this repo.

You can also use `bundle exec rake rubocop:auto_correct` to fix most of the issues automatically.
Please double check the results before committing!

If your project needs relaxed settings, you can generate a `.rubocop_todo.yml`
file using `bundle exec rake rubocop AUTOGEN=1`.

If you do not want to run `scss-lint` on your project (yet),
you can create a `.skip_scss_lint` file in your project root.

## Installation

Add this to the development/test group in your Gemfile:

```ruby
gem 'rubocop-ci', github: 'ad2games/rubocop-ci'
```

Run `bundle exec rake rubocop` before/after your tests on your CI.

## Changes

If you work at ad2games, please open a pull request if you want to change the rubocop config.
Merge it only if it has been approved by the team.

If you want to use this gem for your own company/project, feel free to fork!



