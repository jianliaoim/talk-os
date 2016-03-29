should = require 'should'
request = require 'supertest'
async = require 'async'
Promise = require 'bluebird'

app = require '../../../server/server'
util = require '../../util'

limbo = require 'limbo'
{
  UserModel
  MobileModel
} = limbo.use 'account'

_createUser = (done) ->
  phoneNumber = '18500000000'
  user = new UserModel
  mobile = new MobileModel
    user: user._id
    phoneNumber: phoneNumber
  Promise.all [user.$save(), mobile.$save()]
  .spread (user, mobile) ->
    user.accountToken = user.genAccountToken login: 'mobile'
    util.user = user
    util.mobile = mobile
    done()
  .catch done

describe 'Union#unionMain', ->

  before _createUser

  it 'should get all of the binding union accounts information', (done) ->

    async.auto
      bindGithub: (callback) ->
        options =
          method: 'POST'
          url: '/union/bind/github'
          body:
            accountToken: util.user.accountToken
            code: 'xxx'
        util.request options, (err, res) ->
          callback err
      bindWeibo: (callback) ->
        options =
          method: 'POST'
          url: '/union/bind/weibo'
          body:
            accountToken: util.user.accountToken
            code: 'xxx'
        util.request options, (err, res) ->
          callback err

      getUnionInfo: ['bindGithub', 'bindWeibo', (callback) ->
        request(app).get '/user/accounts'
        .send {accountToken: util.user.accountToken}
        .end (err, res) ->
          data = res.text.match /<script>window\._initialStore = \((.*)\)<\/script>/i

          account = JSON.parse(data[1]).page.accounts

          account.should.have.properties 'phoneNumber'
          account.unions.length.should.eql 2
          account.unions.forEach (union) ->
            union.should.have.properties 'openId', 'refer', 'showname'

          callback err
      ]
    , done
  after util.cleanup
