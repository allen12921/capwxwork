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
set :wxwork_config, {
  web_hook: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=1de12120539-21-4721242-2121-1212'
}
before 'deploy:check', 'wxwork:notify:starting_to_deploy' do
  Rake::Task['wxwork:notify'].invoke('Starting to deploy.')
end
after 'deploy:finishing', 'wxwork:notify:deployment_finished' do
  Rake::Task['wxwork:notify'].invoke('Deployment finished.')
end
```
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
