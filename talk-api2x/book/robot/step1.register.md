## step1: register

### Step1: Register Your Robot
First, initialize a repository start with `tbot-` (e.g. [tbot-jarvis](https://github.com/talk/tbot-jarvis)) and put it in talk's `node_module` directory.

Talk will autoload it as a robot module and activate this robot in the ecosystem.

But, before require this robot, you should register your robot first, as the code shown below:

```coffeescript
register = talk.robot.register
register 'jarvis', (robot) ->  # Register Robot Named `jarvis`
  robot.user = avatarUrl: 'https://dn-files.qbox.me/avatar/jarvis.jpg' # Set AvatarUrl of the Robot
```

Talk will globalize a `talk` variable and you can get the `robot` property from it.

In the callback function of `register`, talk will initialize an instance of the robot object, it is very useful in the following steps.

Talk treat robot as a `normal user`,  so the robot will have `user`, `member` of `room` and other things we can think of in the future.

So now you can set some properties on the robot object, these properties will mapping to the talk database. For example: when you set the avatarUrl of the user, then the robot user will come on stage with the chosen avatar.
