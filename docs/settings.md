### Settings API

#### settings get

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
value = session.settings['Livechat_enabled']
```

#### settings set

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
session = rocket_server.login('username', 'password')
session.settings['Livechat_enabled'] = 'value'
```
