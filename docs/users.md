### Users API

#### users.create

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
user = session.users.create('new_username', 'user@example.com', 'New User', '123456',
                     active: true, send_welcome_email: false)
```

Optional parameters for create are:

:active, :roles, :join_default_channels, :require_password_change, :send_welcome_email, :verified, :custom_fields


#### users.update

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
user = session.users.update('LAjzCDLqggCT7B82M',
  email: 'updated@example.com',
  name: 'Updated Name',
  roles: ['user', 'moderator']
)
```

Optional parameters for update are:

:username, :email, :password, :name, :active, :roles, :join_default_channels, :require_password_change, :send_welcome_email, :verified, :custom_fields


#### users.info

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
user = session.users.info(username: 'some_username')
```

Either user_id (RocketChat's ID) or username can be used.


#### users.getPresence

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
presence_status = session.users.getPresence(username: 'some_username')
```

Either user_id (RocketChat's ID) or username can be used.


#### users.delete

To delete a user, the same options as an info request can be used (`user_id` or `username`).


#### users.list

_N.B. list is also used for searching/querying_ 

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
users = session.users.list(query: { email: 'foo@example.com' })
```


#### users.setAvatar

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
success = session.users.set_avatar('http://image_url')
```

There is an optional parameter user_id, that works if the setting user is allowed to set other's avatar.
