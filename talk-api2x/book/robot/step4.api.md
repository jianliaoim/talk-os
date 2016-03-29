## step4: api

### Step4: Use Api to Explore Talk Database

When robot initialized, talk service will set an `api` object to each robot.

This `api` object is bound to a series of enviroment variables, such as the robot's _sessionUserId. So when your robot call the apis, talk will treat this as a normal user request.

So calling api is something like a `restful` request or `event` in websocket request. For example, you need to say hello to the user sent you message just now, you may want to find out the user's name, so you call `api.member.readOne` to find his/her infomation.

```coffeescript
robot.respond /hello/, (msg, echo) ->
  robot.api.member.readOne _id: msg._creatorId, (err, member) ->
    echo.send "hello #{member?.user?.name}"
```

Most time the apis are as same as the restful apis, so you can check the [restful](/doc/restful/README.html) api list to find out the robot apis.
