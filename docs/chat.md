### Chat API

RocketChat's Chat Messages.

#### chat.delete

Remove a chat message.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
session.chat.delete(room_id: 'some_channel_id', msg_id: 'some_message_id',
                    as_user: false)
```

#### chat.getMessage

Retrieves a chat message for the provided id.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
message = session.chat.get_message(msg_id: 'some_message_id')
```

#### chat.postMessage

Post a message to a RocketChat channel.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
message = session.chat.post_message(room_id: 'some_message_id',
                                    text: 'hello, rocket.chat')
```

Post a message in a thread.

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
message = session.chat.post_message(room_id: 'some_message_id',
                                    text: 'hello, rocket.chat',
                                    tmid: 'gcGai9bRREqokjyPc')
```

#### chat.update

Update an existing message.
 
```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
session.chat.update(room_id: 'some_channel_id', msg_id: 'some_message_id',
                    text: 'Hi, Rocket.chat')
```
