should = require 'should'
Promise = require 'bluebird'

limbo = require 'limbo'

app = require '../app'
{prepare, cleanup, request, requestAsync} = app

{
  UserModel
} = limbo.use 'talk'

describe 'Activity#CURD', ->

  before prepare

  it 'should create an activity when create new room', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'activity:create' and data.type is 'room'
            hits |= 0b1
            data.should.have.properties 'target', 'type', 'text', 'creator'
            data.target.topic.should.eql 'New room'
            data.text.should.eql "{{__info-create-room}}"
          resolve() if hits is 0b1
        catch err
          reject err

    $createRoom = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/rooms'
        body:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id
          topic: 'New room'
      requestAsync options
      .spread (res) -> app.room3 = res.body

    Promise.all [$createRoom, $broadcast]
    .nodeify done

  it 'should create an activity when create new story', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'activity:create' and data.type is 'story'
            hits |= 0b1
            data.should.have.properties 'target', 'type', 'text', 'creator'
            data.text.should.eql "{{__info-create-topic-story}}"
          resolve() if hits is 0b1
        catch err
          reject err

    $createStory = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/stories'
        body:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id
          category: 'topic'
          data:
            title: 'New topic'
      requestAsync options

    Promise.all [$createStory, $broadcast]
    .nodeify done

  it 'should create an activity when add new users', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'activity:create' and data.text is '{{__info-invite-team-member}} tt'
            hits |= 0b1
          resolve() if hits is 0b1
        catch err
          reject err

    $user = Promise.resolve().then ->
      user = new UserModel
        name: 'tt'
      user.$save()

    $inviteNewUser = $user.then (user) ->
      options =
        method: 'POST'
        url: "/teams/#{app.team1._id}/invite"
        body:
          _sessionUserId: app.user1._id
          _userId: user._id
      requestAsync options

    Promise.all [$inviteNewUser, $broadcast]
    .nodeify done

  it 'should read an list of activities', (done) ->

    $activities = Promise.resolve().then ->
      options =
        method: 'GET'
        url: '/activities'
        qs:
          _sessionUserId: app.user2._id
          _teamId: app.team1._id

      requestAsync options

      .spread (res) ->
        res.body.length.should.eql 2
        app.activity1 = res.body[0]
        res.body[0].text.should.eql '{{__info-invite-team-member}} tt'

    $activities.nodeify done

  it 'should remove activities when remove room', (done) ->

    $removeRoom = Promise.resolve().then ->
      options =
        method: 'DELETE'
        url: "/rooms/#{app.room3._id}"
        body: _sessionUserId: app.user1._id
      requestAsync options

    $activities = $removeRoom.then ->
      options =
        method: 'GET'
        url: '/activities'
        qs:
          _sessionUserId: app.user2._id
          _teamId: app.team1._id

      requestAsync options
      .spread (res) -> res.body.length.should.eql 1

    $activities.nodeify done

  it 'should remove an activity by team admin', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'activity:remove'
            hits |= 0b1
          resolve() if hits is 0b1
        catch err
          reject err

    $activity = Promise.resolve().then ->
      options =
        method: 'DELETE'
        url: "/activities/#{app.activity1._id}"
        body: _sessionUserId: app.user1._id
      requestAsync options

    $activity.nodeify done

  after cleanup
