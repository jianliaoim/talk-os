jwt = require 'jsonwebtoken'
_ = require 'lodash'

config = require '../config/prod'

createToken = (userId) ->
  jwt.sign _.assign({}, {}, _id: userId),
    config.accountCookieSecret
  ,
    expiresIn: config.accountCookieExpires
    noTimestamp: true

userId = process.argv[2]

console.log 'UserId:', userId
console.log 'Token:', createToken userId
