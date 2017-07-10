[![Travis Build Status](http://img.shields.io/travis/abrom/rocketchat-ruby.svg?style=flat)](https://travis-ci.org/abrom/rocketchat-ruby)
[![Code Climate Score](http://img.shields.io/codeclimate/github/abrom/rocketchat-ruby.svg?style=flat)](https://codeclimate.com/github/abrom/rocketchat-ruby)
[![Gem Version](http://img.shields.io/gem/v/rocketchat.svg?style=flat)](#)

# Rocket.Chat REST API for Ruby

This is a gem wrapping the v1 REST API for [Rocket.Chat](https://rocket.chat/).

The gem is based on a fork of http://github.com/int2xx9/ruby-rocketchat however that gem implemented v0.1
of the Rocket.Chat API and it was not forward compatible. Thanks to [@int2xx9](http://github.com/int2xx9) for the
framework on which this gem was based 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rocketchat'
```

And then execute:

    $ bundle


## Supported API calls

This gem supports the following Rocket.Chat APIs (Tested against Rocket.Chat v0.54)

#### Miscellaneous information
* [/api/v1/info](#info)

#### Authentication
* [/api/v1/login](#authentication)
* [/api/v1/logout](#authentication)
* /api/v1/me

#### Channels
* [/api/v1/channels.create](docs/channels.md#channelscreate)
* [/api/v1/channels.delete](docs/channels.md#channelsdelete)
* [/api/v1/channels.info](docs/channels.md#channelsinfo)
* [/api/v1/channels.invite](docs/channels.md#channelsinvite)
* [/api/v1/channels.join](docs/channels.md#channelsjoin)
* [/api/v1/channels.leave](docs/channels.md#channelsleave)
* [/api/v1/channels.list](docs/channels.md#channelslist)
* [/api/v1/channels.rename](docs/channels.md#channelsrename)
* [/api/v1/channels.setDescription](docs/channels.md#channelsset_attr)
* [/api/v1/channels.setJoinCode](docs/channels.md#channelsset_attr)
* [/api/v1/channels.setPurpose](docs/channels.md#channelsset_attr)
* [/api/v1/channels.setReadOnly](docs/channels.md#channelsset_attr)
* [/api/v1/channels.setTopic](docs/channels.md#channelsset_attr)
* [/api/v1/channels.setType](docs/channels.md#channelsset_attr)

#### Groups
* /api/v1/groups.create
* /api/v1/groups.delete
* /api/v1/groups.info
* /api/v1/groups.invite
* /api/v1/groups.leave
* [/api/v1/groups.list](docs/groups.md#groupslist)
* /api/v1/groups.rename
* /api/v1/groups.setDescription
* /api/v1/groups.setPurpose
* /api/v1/groups.setReadOnly
* /api/v1/groups.setTopic
* /api/v1/groups.setType

#### Users
* [/api/v1/users.create](docs/users.md#userscreate)
* [/api/v1/users.createToken](docs/users.md#userscreatetoken)
* [/api/v1/users.delete](docs/users.md#usersdelete)
* [/api/v1/users.getPresence](docs/users.md#usersgetpresence)
* [/api/v1/users.info](docs/users.md#usersinfo)
* [/api/v1/users.list](docs/users.md#userslist)
* [/api/v1/users.resetAvatar](docs/users.md#usersresetavatar)
* [/api/v1/users.setAvatar](docs/users.md#userssetavatar)
* [/api/v1/users.update](docs/users.md#usersupdate)

#### Settings
* [/api/v1/settings/:_id](docs/settings.md#settingsget)


## Usage

#### info
To get Rocket.Chat version

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
info = rocket_server.info
puts "Rocket.Chat version: #{info.version}"
```

#### authentication
To logout from a server:

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
# ... use the API ...
session.logout
```

#### debugging
To debug the communications between the gem and Rocket.Chat, there is a debug option.
It accepts a stream for logging.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/', debug: $stderr)
```


For details of specific APIs:

* [Users](docs/users.md)
* [Settings](docs/settings.md)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abrom/rocketchat-ruby.

Note that spec tests are appreciated to minimise regressions. Before submitting a PR, please ensure that:
 
```bash
$ rspec
```
and

```bash
$ rubocop
```
both succeed 

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
