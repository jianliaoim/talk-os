should = require 'should'
Promise = require 'bluebird'
app = require '../app'
limbo = require 'limbo'
{prepare, cleanup, requestAsync} = app

{
  RoomModel
  UserModel
  MemberModel
} = limbo.use 'talk'

describe 'Invitation#Read/Remove', ->

  before (done) ->
    $prepare = Promise.promisify(prepare).apply this
    $invite = $prepare.then ->
      options =
        method: 'POST'
        url: "/rooms/#{app.room1._id}/invite"
        body:
          mobile: '13011111111'
          _sessionUserId: app.user1._id
      requestAsync options
      .spread (res, invitee) -> app.invitee1 = invitee
    $invite.nodeify done

  it 'should read invitations of a team', (done) ->

    $invitations = Promise.resolve().then ->
      options =
        method: 'GET'
        url: "/invitations"
        qs:
          _sessionUserId: app.user1._id
          _teamId: app.team1._id
      requestAsync options
      .spread (res, invitations) ->
        invitations.length.should.eql 1
        invitations.forEach (invitation) ->
          invitation.key.should.eql 'mobile_13011111111'

    $invitations.nodeify done

  it 'should remove an invitation', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'invitation:remove'
            hits |= 0b1
            "#{data._teamId}".should.eql "#{app.team1._id}"
          resolve() if hits is 0b1
        catch err
          reject err

    $removeInvite = Promise.resolve().then ->
      options =
        method: 'DELETE'
        url: "/invitations/#{app.invitee1._id}"
        body:
          _sessionUserId: app.user1._id
      requestAsync options

    Promise.all [$removeInvite, $broadcast]
    .nodeify done

  after cleanup
