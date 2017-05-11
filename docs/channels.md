### Channels API

Channels are RocketChat's public rooms.

#### channels.create

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.create('new_channelname',
                     members: ['username1', 'username2'])
```

Optional parameters for create are:

:members, :read_only, :custom_fields


#### channels.info

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.info(name: 'some_channelname')
```

Either room_id (RocketChat's ID) or name can be used.


#### channels.delete

To delete a channel, the same options as an info request can be used (`room_id` or `name`).


#### channels.invite

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.invite(name: 'some_channelname', username: 'some_username')
```

Either room_id (RocketChat's ID) or name can be used.
The same applies to user_id and username.


#### channels.join

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.join(name: 'some_channelname')
```

Either room_id (RocketChat's ID) or name can be used.


#### channels.leave

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.leave(name: 'some_channelname')
```

Either room_id (RocketChat's ID) or name can be used.


#### channels.list

_N.B. list is also used for searching/querying_

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channels = session.channels.list(query: {usernames: 'friend-username'})
```


### channels.rename

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.info(name: 'some_channelname')
session.channels.rename(channel.id, 'new_channelname')
```
