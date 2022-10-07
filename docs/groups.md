### Groups API

Groups are RocketChat's private rooms.

#### groups.list

_N.B. groups.list, contrary to the other lists can only be used for listing_

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
groups = session.groups.list(offset: 40)
```


#### groups.addAll

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
success = session.groups.add_all(room_id: 'ByehQjC44FwMeiLbX')
```

Optional parameter for add_all is `active_users_only` (default false)

_N.B. the addAll API endpoint requires the calling user to have the `admin` role_


#### groups.addOwner

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
success = session.groups.add_owner(name: 'some_groupname', username: 'some_username')
```

Either room_id (RocketChat's ID) or name can be used.
The same applies to user_id and username.


#### groups.removeOwner

To remove an owner from a group, the same options as an `add_owner` request can be used.


#### groups.addModerator

To add a moderator to a group, the same options as an `add_owner` request can be used.


#### groups.removeModerator

To remove a moderator from a group, the same options as an `add_owner` request can be used.

### groups.members

This method returns the users of participants of a private group.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
session.groups.members(name: 'some_channel_name')

```

#### groups.kick

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.groups.kick(room_id: 'some-room-id', user_id: 'some-user-id')
```
