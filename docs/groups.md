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
