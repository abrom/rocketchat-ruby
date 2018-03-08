### Authentication API

Authentication in Rocket.chat

#### login

```ruby
require 'rocketchat'

rocket_server = RocketChat::Server.new('http://your.server.address/')
begin
  session = rocket_server.login('username', 'password')
rescue => e
  # Unauthorized or HTTPError, StatusError
  puts "reason: #{e.message}"
end

```

#### logout

```ruby
require 'rocketchat'

begin
  # after login
  session.logout
rescue => e
  # [HTTPError, StatusError]
  puts "reason: #{e.message}"
end
```
