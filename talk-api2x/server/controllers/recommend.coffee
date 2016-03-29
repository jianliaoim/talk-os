_ = require 'lodash'
async = require 'async'
util = require '../util'
app = require '../server'

limbo = require 'limbo'

{
  UserModel
} = limbo.use 'talk'

# Copy from [email-autocomplete](https://github.com/10w042/email-autocomplete/blob/master/src/jquery.email-autocomplete.js)
# And [度娘](http://site.baidu.com/list/18youxiang.htm)
emailDomains = [
  # Domestic
  "163.com"
  "126.com"
  "qq.com"
  "sina.com.cn"
  "sina.com"
  "139.com"
  "tom.com"
  "21cn.com"
  "sogou.com"
  "189.cn"
  "eyou.com"
  "yeah.net"
  "sohu.com"
  "263.net"
  "foxmail.com"
  # International
  "yahoo.com"
  "google.com"
  "hotmail.com"
  "gmail.com"
  "me.com"
  "aol.com"
  "mac.com"
  "live.com"
  "comcast.net"
  "googlemail.com"
  "msn.com"
  "hotmail.co.uk"
  "yahoo.co.uk"
  "facebook.com"
  "verizon.net"
  "sbcglobal.net"
  "att.net"
  "gmx.com"
  "mail.com"
  "outlook.com"
  "icloud.com"
]

module.exports = recommendController = app.controller 'recommend', ->

  # Recommend friends by emails
  @action 'friends', (req, res, callback) ->
    {_sessionUserId} = req.get()
    user = {}  # The user self
    domain = null  # Email domain of user
    totalCount = 10  # Totally count number
    users = []  # Final users
    async.waterfall [
      (next) ->
        UserModel.findOne
          _id: _sessionUserId
        , next
      # Find users in talk db
      (_user, next) ->
        user = _user
        domain = user.email?.split('@')[1]
        return callback(null, []) unless domain? and domain not in emailDomains
        UserModel.find
          _id: $ne: _sessionUserId
          emailDomain: domain
          isRobot: false
          isGuest: false
        .limit totalCount * 2
        .exec next
      (_users, next) ->
        users = util.arrRandom(_users, totalCount)
        next null, users
    ], callback
