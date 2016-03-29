should = require 'should'
async = require 'async'
limbo = require 'limbo'
db = limbo.use 'talk'
app = require '../app'
{prepare, clear, request} = app

describe 'DeviceToken#Create', ->

  before prepare

  it 'should create a devicetoken', (done) ->
    options =
      method: 'post'
      url: 'devicetokens'
      headers:
        'X-Client-Type': 'ios'
        'X-Client-Id': 'abc'
      body: JSON.stringify
        _sessionUserId: app.user1._id
        token: 'abc'
    request options, (err, res, devicetoken) ->
      devicetoken.should.have.properties '_userId', 'token', 'type', 'clientId'
      done err

  after clear
