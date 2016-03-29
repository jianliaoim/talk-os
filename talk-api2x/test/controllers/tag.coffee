should = require 'should'
async = require 'async'
limbo = require 'limbo'
app = require '../app'
{prepare, cleanup, request} = app

{
  RoomModel
} = limbo.use 'talk'

describe 'Tag#Create/Update/Read/Remove', ->

  before prepare

  it 'should create a tag and receive a broadcast notification', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (channel, event, data) ->
          app.tag = JSON.parse(JSON.stringify(data))
          event.should.eql 'tag:create'
          channel.should.eql "team:#{app.team1._id}"
          data.name.should.eql "团队笔记"
          callback()
      createTag: (callback) ->
        options =
          method: 'POST'
          url: "/tags"
          body: JSON.stringify
            _teamId: app.team1._id
            _sessionUserId: app.user1._id
            name: '团队笔记'
        request options, callback
    , done

  it 'should update a tag and receive a broadcast notification', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (channel, event, data) ->
          event.should.eql 'tag:update'
          channel.should.eql "team:#{app.team1._id}"
          data.name.should.eql "新笔记"
          callback()
      updateTag: (callback) ->
        options =
          method: 'PUT'
          url: "/tags/#{app.tag._id}"
          body:
            _sessionUserId: app.user1._id
            name: '新笔记'
        request options, callback
    , done

  it 'should read a tag list of team', (done) ->

    options =
      method: 'GET'
      url: "/tags"
      qs:
        _teamId: app.team1._id
        _sessionUserId: app.user1._id
    request options, (err, res, tags) ->
      tags.length.should.eql 1
      tags.forEach (tag) -> tag.name.should.eql "新笔记"
      done err

  it 'should remove a tag', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (channel, event, data) ->
          event.should.eql "tag:remove"
          channel.should.eql "team:#{app.team1._id}"
          data.should.have.properties 'name', '_creatorId'
          callback()
      removeTag: (callback) ->
        options =
          method: 'DELETE'
          url: "/tags/#{app.tag._id}"
          body:
            _sessionUserId: app.user1._id
        request options, callback
    , done

  after cleanup
