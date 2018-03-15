### Chat API

Chat are RocketChat's Chat Messages.

#### chat.delete

Remove chat message.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.create('new_channelname',
                     members: ['username1', 'username2'])
message = session.chat.post_message(room_id: channel.id,
                     text: 'hello, rocket.chat')
session.chat.delete(room_id: channel.id, 
                     msg_id: message.id, as_user: false)
```

#### chat.getMessage

Retrieves a single chat message by the provided id.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.create('new_channelname',
                     members: ['username1', 'username2'])
message = session.chat.post_message(room_id: channel.id,
                     text: 'hello, rocket.chat')
message = session.chat.get_message(msg_id: message.id)
```

#### chat.postMessage

send message to rocket.chat channel.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.create('new_channelname',
                     members: ['username1', 'username2'])
message = session.chat.post_message(room_id: channel.id,
                     text: 'hello, rocket.chat')
```

#### chat.update

update message.
 
```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
channel = session.channels.create('new_channelname',
                     members: ['username1', 'username2'])
message = session.chat.post_message(room_id: channel.id,
                     text: 'hello, rocket.chat')
session.chat.update(room_id: channel.id, 
                     msg_id: message.id, text: 'Hi, Rocket.chat')
```
