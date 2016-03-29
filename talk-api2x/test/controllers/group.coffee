should = require 'should'
Promise = require 'bluebird'
limbo = require 'limbo'
app = require '../app'
{prepare, clear, requestAsync} = app

describe 'Group#CURD', ->

  before prepare

  it 'should create a group', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        if event is 'group:create'
          data.should.have.properties 'members', '_memberIds', 'name'
          data._memberIds.length.should.eql 1
          data._memberIds.should.containEql "#{app.user1._id}"
          app.group1 = data
          hits |= 0b1
        resolve() if hits is 0b1

    $group = Promise.resolve().then ->
      options =
        method: 'POST'
        url: 'groups'
        body:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id
          name: 'XXX'
          _memberIds: [app.user1._id]
      requestAsync options

    Promise.all [$broadcast, $group]
    .nodeify done

  it 'should read groups', (done) ->
    $groups = Promise.resolve().then ->
      options =
        method: 'GET'
        url: "groups"
        body:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id
      requestAsync options
      .spread (res, groups) ->
        groups.length.should.eql 1

    $groups.nodeify done

  it 'should update a group', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        if event is 'group:update'
          data.name.should.eql 'YYY'
          hits |= 0b1
        resolve() if hits is 0b1

    $group = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "groups/#{app.group1._id}"
        body:
          _sessionUserId: app.user1._id
          name: 'YYY'
      requestAsync options

    Promise.all [$broadcast, $group]
    .nodeify done

  it 'should add members to a group', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        if event is 'group:update'
          data._memberIds.length.should.eql 2
          data._memberIds.should.containEql "#{app.user2._id}"
          data._memberIds.should.containEql "#{app.user1._id}"
          hits |= 0b1
        resolve() if hits is 0b1

    $group = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "groups/#{app.group1._id}"
        body:
          _sessionUserId: app.user1._id
          addMembers: [app.user2._id]
      requestAsync options

    Promise.all [$broadcast, $group]
    .nodeify done

  it 'should remove members from a group', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        if event is 'group:update'
          data._memberIds.length.should.eql 1
          data._memberIds.should.containEql "#{app.user1._id}"
          hits |= 0b1
        resolve() if hits is 0b1

    $group = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "groups/#{app.group1._id}"
        body:
          _sessionUserId: app.user1._id
          removeMembers: [app.user2._id]
      requestAsync options

    Promise.all [$broadcast, $group]
    .nodeify done

  it 'should remove a group', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        if event is 'group:remove'
          "#{data._id}".should.eql "#{app.group1._id}"
          hits |= 0b1
        resolve() if hits is 0b1

    $group = Promise.resolve().then ->
      options =
        method: 'DELETE'
        url: "groups/#{app.group1._id}"
        body:
          _sessionUserId: app.user1._id
      requestAsync options

    Promise.all [$broadcast, $group]
    .nodeify done

  after clear
