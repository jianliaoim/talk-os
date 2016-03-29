## step2: respond

### Step2: Design Your Robot

Now it's time to design your robot.

When user typed `@your-robot-name` and send some messages, talk will proxy these messages to your robot, and you can use the `respond` method to reply to users, or ignore these messages.

The method called `respond` will take two params: `regexp` and `fn`, that is to say, you need to write your regular expression to grep the message and reply to user in your `fn` method.

There is a simple hello world demo:

```coffeescript
robot.respond /^hello/, (msg, echo) -> echo.send('Hello Talk!')
```

`fn` will apply two arguments, the first is a message object like `{_creatorId: 'xxx', content: 'hello world'}`, you can get some basic message info in it, such as `_creatorId`, `_roomId`, `content` and `created` datetime object. The next is an `echo` object.

The `echo` object only works in the `fn` scope, you can send messages to user by `echo.send`, or emit an event by `echo.emit`, the `echo` object will deal with others variables, such as `_roomId`, `_creatorId`.

You can define a lot of `respond` method in the robot, but the order of responds make sence. When a `respond` method got the message by the matched regular expression, the other `respond` method will not be called, unless you return `false` in the current `respond` method.

```coffeescript
robot.respond /^hello/, (msg, echo) ->
  echo.send('Hello First!')
  return false  # will pass message to the next respond method

robot.respond /^hello/, (msg, echo) ->
  echo.send('Hello Second!')  # the next respond method will not be called

robot.respond /^hello/, (msg, echo) ->
  echo.send('Hello Third!')  # this method will not be called
```

So, take care of your `respond` methods and try to start with your own robot.
