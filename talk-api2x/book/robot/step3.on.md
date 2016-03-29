## step3: on

### Step3: Do Everything With Your Robot

Sometimes you may think that `respond` is not enough. You are too enthusiastic to take over the user's every move.

Talk emit every event to robots, you can use `on` method to respond to these events.

For example, when some user join in the room, talk will emit a 'room:join' event to every user, include robots, so you can send the welcome message to user by respond to this event.

```coffeescript
robot.on 'room:join', (data, echo) ->
  username = data.user.name
  echo.send("#{username} has joined the room, welcome!")
```

The handling method will got the broadcast data of event and an `echo` object, the same as `echo` in `respond` method.
