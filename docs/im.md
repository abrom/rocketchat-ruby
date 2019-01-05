### IM API

RocketChat's IM interface.

#### im.create

Create a direct message.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
room = session.im.create(username: 'rocket.cat')
```

#### im.counters

Retrieves the count information using room_id *or* username

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
im_summary = session.im.counters(room_id: 'room_id', username: 'rocket.cat')
```
