should = require 'should'
async = require 'async'
limbo = require 'limbo'
db = limbo.use 'talk'

app = require '../app'
{prepare, clear, request} = app

describe 'Preference#ReadOne', ->

  before prepare

  it 'should preference of user1', (done) ->
    options =
      method: 'get'
      url: 'preferences'
      qs:
        _sessionUserId: app.user1._id
    request options, (err, res, preference) ->
      preference._id.should.eql app.user1._id
      done err

  after clear

describe 'Preference#Update', ->

  before prepare

  it 'should update preference of user1', (done) ->
    options =
      method: 'put'
      url: 'preferences'
      body: JSON.stringify
        _sessionUserId: app.user1._id
        desktopNotification: true
        displayMode: 'slim'
    request options, (err, res, preference) ->
      preference.desktopNotification.should.eql true
      preference.displayMode.should.eql 'slim'
      done err

  after clear
