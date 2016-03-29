jwt = require 'jsonwebtoken'
_ = require 'lodash'

user =
  "name": "张三"
  "uid": "uid"
  "app": "talk"
  "login": "mobile"

secret = "xxx"

user.token = jwt.sign user, secret

console.log user

setTimeout ->
  appUser = _.omit user, 'token'
  appUser._id = 'appid'
  appUser.token = jwt.sign appUser, secret
  console.log appUser
, 2000
