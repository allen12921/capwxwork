# Wxwork

Send notification message to your Wxwork about your Rails Capistrano deployment via webhook.

## Installation

Add this line to your application's Gemfile:

```ruby
 gem 'capwxwork', git: 'https://github.com/allen12921/capwxwork.git', require: false
```

And then execute:

    $ bundle

## Usage

Add this line to your `Capfile`:

```ruby
require 'capwxwork', require: false
```

Setup in `config/deploy.rb`. Example:

```ruby

```
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
