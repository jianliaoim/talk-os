should = require 'should'
async = require 'async'
Promise = require 'bluebird'
app = require '../app'
db = require('limbo').use 'talk'
{prepare, clear, cleanup, request, requestAsync} = app

{
  RoomModel
  UserModel
  MemberModel
  NotificationModel
  PreferenceModel
} = db

describe 'Room#Create', ->

  before prepare

  it 'should create a room called Bedroom', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->  # Wait for the room broadcast
          event.should.eql 'room:create'
          data.should.have.properties 'topic', '_teamId'
          callback()
      createRoom: (callback) ->
        options =
          method: 'post'
          url: "rooms"
          body: JSON.stringify
            _teamId: app.team1._id
            _sessionUserId: app.user1._id
            _memberIds: [app.user2._id, app.user1._id]
            topic: '话题'
            purpose: 'KILL BILL'
        request options, (err, res, room) ->
          room.should.have.properties '_creatorId', '_teamId', 'topic', 'members', '_memberIds'
          room._teamId.should.eql(app.team1._id)
          room._creatorId.should.eql(app.user1._id)
          room.purpose.should.eql 'KILL BILL'
          room.members.length.should.eql 2
          room._memberIds.length.should.eql 2
          room.memberCount.should.eql 2
          room.members[0]._id.should.eql app.user1._id
          room.members[1]._id.should.eql app.user2._id
          room.pinyin.should.eql 'huati'
          room.pinyins.should.eql ['huati']
          callback(err)
    , done

  after clear

describe 'Room#Update', ->

  before prepare

  it 'should set the room purpose and broadcast to the team', (done) ->
    async.auto
      broadcast: (callback) ->
        num = 0
        app.broadcast = (room, event, data) ->
          num += 1
          if event is 'room:update'
            data.should.have.properties 'topic', '_teamId', 'purpose'
          if event is 'message:create'
            data.isSystem.should.eql true
            data.body.should.eql '{{__info-update-topic}} 新话题 - hi'
          callback() if num is 2
      update: (callback) ->
        options =
          method: 'put'
          url: "rooms/#{app.room1._id}"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            topic: "新话题"
            purpose: 'hi'
        request options, (err, res, room) ->
          room.purpose.should.eql 'hi'
          room.pinyin.should.eql 'xinhuati'
          room.pinyins.should.eql ['xinhuati']
          callback err
    , done

  after clear

describe 'Room#AddMember', ->

  before prepare

  it 'should add members into room', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'room:update'
            hits |= 0b1
            data.members.length.should.eql 2
            _memberIds = data.members.map (member) -> "#{member._id}"
            _memberIds.should.containEql "#{app.user1._id}"
            _memberIds.should.containEql "#{app.user2._id}"
          if event is 'message:create' and data.body is "{{__info-invite-members}} dajiangyou2"
            hits |= 0b10
          resolve() if hits is 0b11
        catch err
          reject err

    $addMembers = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "/rooms/#{app.room2._id}"
        body:
          _sessionUserId: app.user1._id
          addMembers: [app.user2._id]
      requestAsync options

    Promise.all [$broadcast, $addMembers]
    .nodeify done

  it 'should remove members from room', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'room:update'
            hits |= 0b1
            data.members.length.should.eql 1
            _memberIds = data.members.map (member) -> "#{member._id}"
            _memberIds.should.containEql "#{app.user1._id}"
          if event is 'message:create' and data.body is '{{__info-remove-members}} dajiangyou2'
            hits |= 0b10
          resolve() if hits is 0b11
        catch err
          reject err

    $removeMembers = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "/rooms/#{app.room2._id}"
        body:
          _sessionUserId: app.user1._id
          removeMembers: [app.user2._id]
      requestAsync options

    Promise.all [$broadcast, $removeMembers]
    .nodeify done

  after cleanup

describe 'Room#Join', ->

  before (done) ->
    async.auto
      prepare: prepare
      quitUser1: ['prepare', (callback) ->
        MemberModel.update
          user: app.user1._id
          room: app.room1._id
        , isQuit: true
        , callback
      ]
    , done

  it 'should join a room and get detail infomation of this room', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'room:join'
            data.should.have.properties 'name', 'avatarUrl', '_roomId'
            data._roomId.should.eql app.room1._id
            callback()
      joinSucc: (callback) ->  # Join user2 to the room
        options =
          method: 'POST'
          url: "rooms/#{app.room1._id}/join"
          body: JSON.stringify
            _sessionUserId: app.user1._id
        request options, (err, res, room) ->
          room.should.have.properties '_teamId', 'topic', 'members', 'latestMessages', 'unread'
          (room.members.some (member) -> member._id is app.user1._id).should.eql true
          callback err
      joinFail: (callback) ->  # Join user2 to the room, it will fail, trust me
        options =
          method: 'POST'
          url: "rooms/#{app.room2._id}/join"
          body: JSON.stringify
            _sessionUserId: app.user2._id
        request options, (err, res, errObj) ->
          errObj.code.should.eql(204)
          callback()
    , done

  it 'should join a leaved room and get the correct member list', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'room:join'
            data.should.have.properties 'name', 'avatarUrl', '_roomId'
            data._roomId.should.eql app.room1._id
            callback()
      leaveRoom: (callback) ->
        db.member.findOneAndUpdate
          user: app.user1._id
          room: app.room1._id
        ,
          isQuit: true
        , callback
      joinRoom: ['leaveRoom', (callback) ->  # Join user1 to room1
        options =
          method: 'post'
          url: "rooms/#{app.room1._id}/join"
          body: JSON.stringify
            _sessionUserId: app.user1._id
        request options, (err, res, room) ->
          _userIds = room.members.map (user) -> user._id
          _userIds.should.containEql "#{app.user1._id}"
          _userIds.should.containEql "#{app.user2._id}"
          callback()
      ]
    , done

  after clear

describe 'Room#Remove', ->

  before prepare

  it 'should remove room', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'room:remove'
            data._id.should.eql app.room1._id
            callback()
      remove: (callback) ->
        options =
          method: 'delete'
          url: "rooms/#{app.room1._id}"
          body: JSON.stringify
            _sessionUserId: app.user1._id
        request options, (err, res, room) ->
          room.should.have.properties 'topic'
          callback err
    , done

  after clear

describe 'Room#Leave', ->

  before prepare

  it 'should leave the room and broadcast a room:leave message to users', (done) ->

    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (room, event, data) ->
          if event is 'room:leave'
            hits |= 0b1
            data.should.have.properties '_roomId', '_userId'
            data._userId.should.eql app.user1._id
            data._roomId.should.eql app.room1._id
          if event is 'notification:update'
            hits |= 0b10
            "#{data._teamId}".should.eql "#{app.team1._id}"
          callback() if hits is 0b11
      createNotification: (callback) ->
        notification = new NotificationModel
          target: app.room1._id
          type: 'room'
          user: app.user1._id
          team: app.team1._id
        notification.save (err, notification) -> callback err, notification
      leave: (callback) ->
        options =
          method: 'post'
          url: "rooms/#{app.room1._id}/leave"
          body: JSON.stringify
            _sessionUserId: app.user1._id
        request options, callback
      checkPreference: ['leave', (callback) ->
        PreferenceModel.findOne
          _id: app.user1._id
        , (err, preference) ->
          should(preference?._latestRoomId).be.empty()
          callback err
      ]
    , done

  after clear

describe 'Room#Invite', ->

  before (done) ->
    async.auto
      prepare: prepare
      createUser3: ['prepare', app.createUser3]
    , done

  it 'should invite an existing user by email', (done) ->
    async.auto
      broadcast: (callback) ->
        num = 0
        app.broadcast = (room, event, data) ->
          if event is 'room:join' and room.match /^team/
            num += 1
            data.should.have.properties 'room'
            data._teamId.should.eql app.team1._id
            data._roomId.should.eql "#{app.room1._id}"
            data.emailForLogin.should.eql app.user3.emailForLogin
          if event is 'room:join' and room.match /^user/
            num += 1
            data.emailForLogin.should.eql app.user3.emailForLogin
          return callback() if num is 2
      invite: (callback) ->
        options =
          method: 'POST'
          url: "rooms/#{app.room1._id}/invite"
          body:
            _sessionUserId: app.user1._id
            email: app.user3.emailForLogin
        request options, (err, res, user) ->
          user.should.have.properties 'role', 'emailForLogin', 'name', '_roomId', '_teamId'
          callback err
    , done

  it 'should invite a nonexistent user by phone number and receive an invitation', (done) ->
    phoneNumber = '13100000000'
    async.auto
      broadcast: (callback) ->
        app.broadcast = (channel, event, data) ->
          if event is 'invitation:create'
            data.should.have.properties '_roomId', '_teamId'
            data._roomId.should.eql app.room1._id
            data._teamId.should.eql app.team1._id
            callback()
      invite: (callback) ->
        options =
          method: 'POST'
          url: "rooms/#{app.room1._id}/invite"
          body:
            _sessionUserId: app.user1._id
            mobile: phoneNumber
        request options, (err, res, invitation) ->
          invitation.should.have.properties 'role', '_roomId', '_teamId'
          callback err
    , done

  after clear

describe 'Room#BatchInvite', ->

  before prepare

  it 'should invite users and send emails', (done) ->
    async.auto
      broadcast: (callback) ->
        num = 0
        app.broadcast = (channel, event, data) ->
          if event is 'invitation:create' and channel.match /^team/
            num += 1
            data.email.should.eql 'lurenjia@teambition.com' if data.email
            data.mobile.should.eql '13111111111' if data.mobile
            data._teamId.should.eql app.team1._id
            data._roomId.should.eql app.room1._id
          callback() if num is 2
      batchInvite: (callback) ->
        options =
          method: 'POST'
          url: "rooms/#{app.room1._id}/batchinvite"
          body:
            _sessionUserId: app.user1._id
            emails: ['lurenjia@teambition.com']
            mobiles: ['13111111111']
        request options, callback
    , done

describe 'Room#Archive', ->

  before (done) ->
    async.auto
      prepare: prepare
      createRoom3: ['prepare', (callback) ->
        async.waterfall [
          (next) ->
            db.room.create
              team: app.team1._id
              creator: app.user1._id
              topic: 'room3'
            , next
          (room, next) ->
            app.room3 = room
            db.member.create
              room: room._id
              user: app.user1._id
            , next
          (member, next) ->
            # Create integration
            room = app.room3
            db.integration.create
              team: app.team1._id
              room: room._id
              category: 'weibo'
              token: app.token
              notifications:
                mention: 1
                comment: 1
              creator: app.user1._id
              url: 'https://github.com/blog.atom'
            , next
        ], callback
      ]
    , done

  it 'should archive a room and get the broadcast event', (done) ->
    async.auto
      broadcast: (callback) ->
        i = 2
        app.broadcast = (room, event, data) ->
          i -= 1
          if event is 'room:archive'
            data.should.have.properties '_teamId', 'isArchived'
            data.isArchived.should.eql true
          if event is 'integration:remove'
            data.category.should.eql 'weibo'
          return callback() if i is 0
      archive: (callback) ->
        options =
          method: 'POST'
          url: "rooms/#{app.room3._id}/archive"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            isArchived: true
        request options, callback
    , done

  after clear

describe 'Room#Guest', ->

  before prepare

  it 'should enable the guest mode of room', (done) ->
    async.auto
      broadcast: (callback) ->
        num = 0
        app.broadcast = (channel, event, data) ->
          if event is 'room:update'
            num += 1
            data.should.have.properties 'guestToken', 'guestUrl'
          if event is 'message:create' and not data.file
            num += 1
            data.should.have.properties 'body', 'creator'
            "#{data._creatorId}".should.eql app.user1._id
            data.body.should.eql '{{__info-enable-guest}}'
          callback() if num is 2
      guest: (callback) ->
        options =
          method: 'POST'
          url: "rooms/#{app.room1._id}/guest"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            isGuestEnabled: true
        request options, callback
    , done

  it 'should disable the guest mode of room', (done) ->
    async.auto
      broadcast: (callback) ->
        num = 0
        app.broadcast = (channel, event, data) ->
          if event is 'room:update'
            num += 1
            should(data.guestToken).eql undefined
            should(data.guestUrl).eql undefined
          if event is 'message:create' and not data.file
            num += 1
            "#{data._creatorId}".should.eql app.user1._id
            data.body.should.eql '{{__info-disable-guest}}'
          callback() if num is 2
      guest: (callback) ->
        options =
          method: 'POST'
          url: "rooms/#{app.room1._id}/guest"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            isGuestEnabled: false
        request options, callback
    , done

  after clear

describe 'Room#RemoveMember', ->

  before (done) ->
    async.auto
      prepare: prepare
      setPrivateRoom: ['prepare', (callback) ->
        RoomModel.findOneAndUpdate
          _id: app.room1._id
        , isPrivate: true
        , callback
      ]
    , done

  it 'should remove member in the private room', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (channel, event, data) ->
          if event is 'room:leave'
            hits |= 0b1
            data.should.have.properties '_userId', '_roomId'
            data._roomId.should.eql app.room1._id
            data._userId.should.eql app.user2._id
          if event is 'message:create'
            hits |= 0b10
            data.body.should.containEql '{{__info-leave-room}}'
          if event is 'notification:update' and data.isHidden is true
            hits |= 0b100
            "#{data._teamId}".should.eql "#{app.team1._id}"
          callback() if hits is 0b111
      createNotification: (callback) ->
        notification = new NotificationModel
          target: app.room1._id
          type: 'room'
          user: app.user2._id
          team: app.team1._id
        notification.save (err, notification) -> callback err, notification
      removeMember: (callback) ->
        options =
          method: 'POST'
          url: "rooms/#{app.room1._id}/removemember"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            _userId: app.user2._id
        request options, callback
    , done

  after clear
