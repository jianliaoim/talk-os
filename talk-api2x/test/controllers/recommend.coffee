should = require 'should'
async = require 'async'
app = require '../app'
limbo = require 'limbo'
db = limbo.use 'talk'
{prepare, clear, request} = app

describe 'Recommend#Friends', ->

  before prepare

  it 'should get recommend friends for dajiangyou1', (done) ->
    options =
      method: 'get'
      url: 'recommends/friends'
      qs: _sessionUserId: app.user1._id
    request options, (err, res, users) ->
      hasUser2 = false
      users.forEach (user) ->
        user.should.have.properties('name', 'avatarUrl', 'email')
        "#{user._id}".should.not.eql "#{app.user1._id}"
        hasUser2 = true if user.email is app.user2.email
      hasUser2.should.eql true
      done err

  after clear
