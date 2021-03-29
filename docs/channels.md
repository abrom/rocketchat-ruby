### Channels API

Channels are RocketChat's public rooms.

#### channels.create

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.create('new_channelname', members: ['username1', 'username2'])
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


#### channels.addAll

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
success = session.channels.add_all(room_id: 'ByehQjC44FwMeiLbX')
```

Optional parameter for add_all is `active_users_only` (default false)

_N.B. the addAll API endpoint requires the calling user to have the `admin` role_


#### channels.addOwner

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
success = session.channels.add_owner(name: 'some_channelname', username: 'some_username')
```

Either room_id (RocketChat's ID) or name can be used.
The same applies to user_id and username.


#### channels.removeOwner

To remove an owner from a channel, the same options as an `add_owner` request can be used.


#### channels.addModerator

To add a moderator to a channel, the same options as an `add_owner` request can be used.


#### channels.removeModerator

To remove a moderator from a channel, the same options as an `add_owner` request can be used.


#### channels.invite

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.invite(name: 'some_channel_name', username: 'some_username')
```

Either room_id (RocketChat's ID) or name can be used.
The same applies to user_id and username.


#### channels.join

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.join(name: 'some_channel_name')
```

Either room_id (RocketChat's ID) or name can be used.


#### channels.leave

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.leave(name: 'some_channel_name')
```

Either room_id (RocketChat's ID) or name can be used.


#### channels.list

_N.B. list is also used for searching/querying_

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channels = session.channels.list(query: { usernames: 'friend-username' })
```


### channels.rename

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.info(name: 'some_channel_name')
session.channels.rename(channel.id, 'new_channel_name')
```


### channels.set\*

This method executes all setSomethingOrOther calls.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
session.channels.set_attr(name: 'some_channel_name', topic: 'Chatting about stuff')
```


### channels.online

This method returns all online users in a channel.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
session.channels.online(name: 'some_channel_name')

```

### channels.members

This method returns all members in a channel.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
session.channels.members(name: 'some_channel_name')

```
