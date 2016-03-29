Snapper
===
Push server build on sockjs and redis pub/sub channel

# Example

```coffeescript
{client} = require 'snapper'
client.use('redis', config)
socketId = '170825e0-c9f4-11e3-8be3-01317850d9b5'
client.send(socketId, 'Hello World')
client.join(socketId, 'room')
client.leave(socketId, 'room')
client.broadcast('room', 'Hello World', socketId)
```

# TODO
* <del>connect from sockjs client</del>
* <del>channel/restful/axon connection adapter</del>
* compiled client embed.js
* auto reconnect in client
* speed limit
* max clients
* message queue

# ChangeLog

## v0.4.0
* Use primus and engine.io

## v0.3.0
* rewrite configurations

## v0.2.0
* remove client

## v0.1.6
* upgrade dependencies

## v0.1.0
* successful connect snapper server with channel/restful/axon adapters
