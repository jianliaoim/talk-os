should = require 'should'
Promise = require 'bluebird'
async = require 'async'
Err = require 'err1st'
db = require('limbo').use 'talk'
app = require '../app'
{prepare, clear, cleanup, request, requestAsync} = app

{
  UserModel
  MemberModel
  TeamModel
  InvitationModel
} = db

_createUnionUser = (callback) ->
  user = new UserModel
    name: "路人丙"
    accountId: "55f7d989c71fd9ffec845f8b"
    unions: [
      refer: 'teambition'
      openId: '55f7d19c85efe377996a1231'
    ]
  app.user3 = user
  user.$save().nodeify callback

describe 'Team#Create', ->

  before prepare

  it 'should create a new team called test', (done) ->
    async.auto
      createTeam: (callback) ->
        options =
          method: 'post'
          url: 'teams'
          body: JSON.stringify
            name: 'test'
            _sessionUserId: app.user1._id
        request options, (err, res, team) ->
          team.name.should.eql 'test'
          (team.members.some (member) -> member._id is app.user1._id).should.eql true
          team.rooms.length.should.eql 1
          app.team3 = team
          callback err, team
      checkRoomMember: ['createTeam', (callback) ->
        room = app.team3.rooms[0]
        room.isGeneral.should.eql true
        MemberModel.findOne
          room: room._id
          user: app.user1._id
          isQuit: false
        , (err, member) ->
          should(member).not.eql null
          callback err
      ]
    , done

  after clear

describe 'Team#Update', ->

  before prepare

  it 'should update the team info and broadcast the new team', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, team, socketId) ->
          if event is 'team:update'
            team.name.should.eql 'new team'
            team.color.should.eql 'tea'
            team.should.have.properties 'shortUrl'
            team.shortUrl.should.containEql 'iamshort'
            callback()
      update: (callback) ->
        options =
          method: 'put'
          url: "teams/#{app.team1._id}"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            name: 'new team'
            color: 'tea'
            shortName: 'iamshort'
        request options, callback
    , done

  after clear

describe 'Team#UpdatePrefs', ->

  before prepare

  it 'should update the prefs with basic properties of team', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (channel, event, data) ->
          if event is 'team.members.prefs:update'
            hits |= 0b1
            channel.should.eql "team:#{app.team1._id}"
            data.alias.should.eql 'BOB'
          if event is 'team:update'
            hits |= 0b10
            data.should.not.have.properties 'prefs'
            data.name.should.eql 'JIJIJI'
          callback() if hits is 0b11
      updateTeamPrefs: (callback) ->
        options =
          method: 'PUT'
          url: "teams/#{app.team1._id}"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            name: 'JIJIJI'
            prefs:
              alias: 'BOB'
              isMute: false
        request options, (err, res, team) ->
          team.prefs.isMute.should.eql false
          callback err
      checkPrefs: ['updateTeamPrefs', (callback) ->
        options =
          method: 'GET'
          url: "teams/#{app.team1._id}"
          qs: _sessionUserId: app.user1._id
        request options, (err, res, team) ->
          return callback err if err
          team.prefs.isMute.should.eql false
          team.prefs.alias.should.eql 'BOB'
          team.members.some (user) ->
            user.prefs?.alias is 'BOB'
          .should.eql true
          callback err
      ]
    , done

  after clear

describe 'Team#Read', ->

  before (done) ->
    async.auto
      prepare: prepare
      createTeam3: ['prepare', (callback) ->
        team = new TeamModel
          name: "team3"
          creator: app.user2._id
        app.team3 = team
        team.save callback
      ]
      createTeam4: ['prepare', (callback) ->
        team = new TeamModel
          name: "team4"
          creator: app.user2._id
        app.team4 = team
        team.save callback
      ]
      createInvitation: ['prepare', 'createTeam3', (callback) ->
        InvitationModel.invite
          email: app.user1.emailForLogin
          team: app.team3._id
        , callback
      ],
    , done

  it 'should read the teams, join teams via inviteCode and invitation', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (channel, event, data) ->
          if event is 'team:join'
            # Two team:join event
            hits |= 0b1
            data.should.have.properties 'name', 'role'
          if event is 'invitation:remove'
            # One invitation:remove event
            hits |= 0b10
            data.email.should.eql app.user1.emailForLogin
          callback() if hits is 0b11
      read: (callback) ->
        options =
          method: 'GET'
          url: 'teams'
          qs:
            _sessionUserId: app.user1._id
        request options, (err, res, teams) ->
          teams.length.should.eql 3
          teams.forEach (team) -> team.should.have.properties 'unread', 'signCode', 'prefs'
          callback err
    , done

  after clear

describe 'Team#Sync', ->

  before prepare

  it 'should read teams from union accounts', (done) ->
    async.auto
      createUnionUser: _createUnionUser
      read: ['createUnionUser', (callback) ->
        options =
          method: 'POST'
          url: 'teams/sync'
          qs:
            _sessionUserId: app.user3._id
            accountToken: "OKKKKKKK"
            refer: 'teambition'
        request options, (err, res, teams) ->
          # Sync two teams from teambition
          teams.length.should.eql 2
          teams.forEach (team) -> team.should.have.properties 'source', 'sourceId', 'sourceName'
          callback err
      ]
    , done

  after cleanup

describe 'Team#Thirds', ->

  before prepare

  it 'should read teams from third-part account', (done) ->

    $user3 = _createUnionUser()

    $thirds = $user3.then (user) ->

      options =
        method: 'GET'
        url: "teams/thirds"
        qs:
          _sessionUserId: user._id
          accountToken: 'OKKKKKKK'
          refer: 'teambition'

      requestAsync(options).spread (res, teams) ->
        teams.length.should.eql 2
        teams.forEach (team) -> team.should.have.properties 'name', 'sourceId'

    $thirds.nodeify done

  after cleanup

describe 'Team#SyncOne', ->

  before prepare

  it 'should sync one team from third-part account', (done) ->

    # Wait for two invitation notification
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        if event is 'invitation:create'
          hits |= 0b1
          data.should.have.properties 'key'
          data.isInvite.should.eql true
        resolve() if hits is 0b1

    $user3 = _createUnionUser()

    $syncOne = $user3.then (user) ->

      options =
        method: 'POST'
        url: "teams/syncone"
        body:
          _sessionUserId: user._id
          accountToken: 'OKKKKKKK'
          refer: 'teambition'
          sourceId: '55f7d19c85efe377996a113f'

      requestAsync(options).spread (res, team) ->
        team.should.have.properties 'source', 'sourceId', 'sourceName'
        team.sourceId.should.eql '55f7d19c85efe377996a113f'

    Promise.all [$broadcast, $syncOne]
    .nodeify done

  after cleanup

describe 'Team#ReadOne', ->

  before prepare

  it 'should read the detail infomation of the team', (done) ->
    options =
      method: 'GET'
      url: "teams/#{app.team1._id}"
      qs: _sessionUserId: app.user1._id
    request options, (err, res, team) ->
      team.should.have.properties 'name', 'members', 'rooms', 'inviteUrl', 'latestMessages'
      team.members.forEach (member) ->
        member.should.have.properties 'role'
      team.rooms.forEach (room) ->
        room.should.have.properties 'topic', 'isQuit'
      done(err)

  it 'should not read the team infomation when user is not member the team', (done) ->
    options =
      method: 'GET'
      url: "teams/#{app.team2._id}"
      qs: _sessionUserId: app.user2._id
    request options, (err, res, errObj) ->
      errObj.code.should.eql 204
      done()

  after clear

describe 'Team#Join', ->

  before prepare

  it 'should join the team by signCode', (done) ->
    async.auto
      broadcast: (callback) ->
        n = 0
        app.broadcast = (channel, event, data) ->
          if event is 'team:join'
            n += 1
            channel.should.eql "team:#{app.team1._id}"
            data.should.have.properties '_teamId', 'team'
            "#{data._id}".should.eql "#{app.user3._id}"
          if event is "message:create"
            n += 1
            data.body.should.eql '{{__info-join-team}}'
          callback() if n is 2
      readOne: (callback) ->
        options =
          method: 'GET'
          url: "teams/#{app.team1._id}"
          qs: _sessionUserId: app.user1._id
        request options, (err, res, team) ->
          app.team1 = team
          callback err
      createNewUser: (callback) ->
        user = new UserModel
          name: 'user3'
        user.save (err, user) ->
          app.user3 = user
          callback err
      join: ['readOne', 'createNewUser', (callback) ->
        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/join"
          body: JSON.stringify
            _sessionUserId: app.user3._id
            signCode: app.team1.signCode
        request options, (err, res, team) ->
          team.should.have.properties 'name', 'signCode'
          callback err
      ]
    , done

  after clear

describe 'Team#Rooms', ->

  before prepare

  it 'should read the room list of team', (done) ->
    options =
      method: 'GET'
      url: "teams/#{app.team1._id}/rooms"
      body:
        _sessionUserId: app.user1._id
    request options, (err, res, rooms) ->
      rooms.length.should.above 0
      rooms.forEach (room) ->
        room.should.have.properties 'topic', '_teamId', 'isQuit', '_memberIds'
        room._memberIds.length.should.above 0
      done err

  after clear

describe 'Team#Members', ->

  before prepare

  it 'should read the member list of team', (done) ->
    options =
      method: 'GET'
      url: "teams/#{app.team1._id}/members"
      body:
        _sessionUserId: app.user1._id
    request options, (err, res, members) ->
      members.length.should.above 0
      members.forEach (user) ->
        user.should.have.properties 'name'
      done(err)

  after clear

describe 'Team#Leave', ->

  before prepare

  it 'should leave the team and broadcast a leave message', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'team:leave'
            data.should.have.properties '_teamId', '_userId'
            data._userId.should.eql app.user1._id
            data._teamId.should.eql app.team1._id
            callback()
      leave: (callback) ->
        options =
          method: 'post'
          url: "teams/#{app.team1._id}/leave"
          body: _sessionUserId: app.user1._id
        request options, (err, res, result) ->
          result.ok.should.eql 1
          callback err
      checkRoomMember: ['leave', (callback) ->
        MemberModel.findOne
          room: app.room1._id
          user: app.user1._id
          isQuit: false
        , (err, member) ->
          should(member).be.empty()
          callback err
      ]
      checkTeamMember: ['leave', (callback) ->
        MemberModel.findOne
          team: app.team1._id
          user: app.user1._id
          isQuit: false
        , (err, member) ->
          should(member).be.empty()
          callback err
      ]
      checkPreference: ['leave', (callback) ->
        db.preference.findOne
          _id: app.user1._id
        , (err, preference) ->
          should(preference?._latestTeamId).be.empty()
          callback err
      ]
    , done

  after clear

describe 'Team#Invite', ->

  before (done) ->
    async.auto
      prepare: prepare
      createUser3: ['prepare', app.createUser3]
    , done

  it 'should invite an existing user by email', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (room, event, data) ->
          if event is 'team:join' and room.match(/^team/)
            hits |= 0b1
            data.should.have.properties 'team'
            data.team._id.should.eql app.team1._id
            data.emailForLogin.should.eql app.user3.emailForLogin
          if event is 'team:join' and room.match(/^user/)
            hits |= 0b10
            data.emailForLogin.should.eql app.user3.emailForLogin
          if event is 'message:create' and data.creator.isRobot
            hits |= 0b100
            data.body.should.eql """
            你好，欢迎加入#{app.team1.name}，在这里你可以与团队成员分享文件，想法和链接，并在不同的话题中参与讨论，「简聊」起来吧。
            #{app.team1.description}
            """
          return callback() if hits is 0b111
      invite: (callback) ->
        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/invite"
          body:
            _sessionUserId: app.user1._id
            email: app.user3.emailForLogin
        request options, (err, res, user) ->
          user.should.have.properties 'emailForLogin', 'name', 'role'
          user.should.not.have.properties 'isInvite'
          callback err
      mailer: (callback) ->
        app.mailer = (email) ->
          {redirectUrl} = email
          redirectUrl.should.containEql "team/#{app.team1._id}"
          app.mailer = ->
          callback()
      checkMember: ['invite', (callback) ->
        MemberModel.findOne
          user: app.user3._id
          team: app.team1._id
        , (err, member) ->
          member.isQuit.should.eql false
          callback err
      ]
    , done

  it 'should invite a nonexistent user by phone number and receive an invitation', (done) ->
    phoneNumber = '13100000000'
    async.auto
      broadcast: (callback) ->
        app.broadcast = (channel, event, data) ->
          if event is 'invitation:create'
            data.should.have.properties '_teamId'
            data.should.not.have.properties '_roomId'
            data.name.should.eql phoneNumber
            data.mobile.should.eql phoneNumber
            callback()
      invite: (callback) ->
        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/invite"
          body:
            _sessionUserId: app.user1._id
            mobile: phoneNumber
        request options, (err, res, invitation) ->
          invitation.should.have.properties 'name', 'role', 'isInvite'
          callback err
    , done

  after clear

describe 'Team#BatchInvite', ->

  before prepare

  it 'should invite users and send emails', (done) ->
    async.auto
      broadcast: (callback) ->
        num = 0
        app.broadcast = (room, event, data) ->
          if event is 'invitation:create' and room.match /^team/
            num += 1
            data.email.should.eql 'lurenjia@teambition.com' if data.email
            data.mobile.should.eql '13111111111' if data.mobile
            data._teamId.should.eql app.team1._id
            data.should.not.have.properties '_roomId'
          callback() if num is 2
      batchInvite: (callback) ->
        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/batchinvite"
          body:
            _sessionUserId: app.user1._id
            emails: ['lurenjia@teambition.com']
            mobiles: ['13111111111']
        request options, callback
    , done

  after clear

describe 'Team#RemoveMember', ->

  before prepare

  it 'should remove member of the team', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'team:leave'
            data._userId.should.eql app.user2._id
            callback()
      removeMember: (callback) ->
        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/removemember"
          body:
            _sessionUserId: app.user1._id
            _userId: app.user2._id
        request options, (err, res, ok) ->
          ok.ok.should.eql 1
          callback err
      checkRoomMember: ['removeMember', (callback) ->
        MemberModel.findOne
          user: app.user2._id
          room: app.room1._id
          isQuit: false
        , (err, member) ->
          should(member).be.empty()
          callback()
      ]
    , done

  after clear

describe 'Team#SetRole', ->

  before prepare

  it 'should set the role of member', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'member:update'
            data.should.have.properties '_userId', '_teamId', 'role'
            data.role.should.eql 'admin'
            callback()
      setRole: (callback) ->
        request
          method: 'POST'
          url: "teams/#{app.team1._id}/setmemberrole"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            _userId: app.user2._id
            role: 'admin'
        , callback
    , done

  after clear

describe 'Team#Pin', ->

  before prepare

  it 'should pin the target of team', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'team:pin'
            data.should.have.properties '_teamId', '_targetId'
            callback()
      pin: (callback) ->
        request
          method: 'POST'
          url: "teams/#{app.team1._id}/pin/#{app.room1._id}"
          body:
            _sessionUserId: app.user1._id
        , callback
      checkPinnedRoom: ['pin', (callback) ->
        request
          method: 'GET'
          url: "teams/#{app.team1._id}"
          qs:
            _sessionUserId: app.user1._id
        , (err, res, team) ->
          team.rooms.length.should.above 0
          team.rooms.forEach (room) ->
            if room._id is app.room1._id
              new Date(room.pinnedAt).getTime().should.above 1000000
              room.pinnedAt.should.not.eql null
          callback()
      ]
    , done

  after clear

describe 'Team#Unpin', ->

  before prepare

  it 'should unpin the target of team', (done) ->

    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'team:unpin'
            data.should.have.properties '_teamId', '_targetId'
            callback()
      unpin: (callback) ->
        request
          method: 'POST'
          url: "teams/#{app.team1._id}/unpin/#{app.user2._id}"
          body: JSON.stringify
            _sessionUserId: app.user1._id
        , callback
    , done

  after clear

describe 'Team#Refresh', ->

  before prepare

  it 'should refresh the invite code of team', (done) ->
    oldInviteCode = app.team1.inviteCode
    oldInviteUrl = app.team1.inviteUrl
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is "team:update"
            data.should.have.properties 'inviteCode', 'inviteUrl'
            data.inviteCode.should.not.eql oldInviteCode
            data.inviteUrl.should.not.eql oldInviteUrl
            callback()
      refreshInviteCode: (callback) ->
        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/refresh"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            properties: inviteCode: 1
        request options, callback
    , done

  it 'should refresh the signCode of team', (done) ->
    async.auto
      readOne: (callback) ->
        options =
          method: 'GET'
          url: "teams/#{app.team1._id}"
          qs: _sessionUserId: app.user1._id
        request options, (err, res, team) ->
          team.should.have.properties 'signCode', 'signCodeExpireAt'
          604800000.should.above(new Date(team.signCodeExpireAt) - Date.now())
          app.team1 = team
          callback err
      refreshSignCode: ['readOne', (callback) ->
        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/refresh"
          body: JSON.stringify
            _sessionUserId: app.user1._id
            properties: signCode: 1
        request options, (err, res, team) ->
          team.signCode.should.not.eql app.team1.signCode
          new Date(team.signCodeExpireAt).should.above(new Date(app.team1.signCodeExpireAt))
          callback err
      ]
    , done

  after clear

describe 'Team#Joinbyinvitecode', ->

  before prepare

  it 'should join the team by invite Code', (done) ->
    async.auto
      broadcast: (callback) ->
        n = 0
        app.broadcast = (channel, event, data) ->
          if event is 'team:join'
            n += 1
            channel.should.eql "team:#{app.team1._id}"
            data.should.have.properties '_teamId', 'team'
            "#{data._id}".should.eql "#{app.user4._id}"
          if event is "message:create"
            n += 1
            data.body.should.eql '{{__info-join-team}}'
          callback() if n is 2
      createNewUser: (callback) ->
        user = new UserModel
          name: 'user4'
        user.save (err, user) ->
          app.user4 = user
          callback err
      join: ['createNewUser', (callback) ->
        options =
          method: 'POST'
          url: "teams/joinbyinvitecode"
          body: JSON.stringify
            _sessionUserId: app.user4._id
            inviteCode: app.team1.inviteCode
        request options, (err, res, team) ->
          team.should.have.properties 'name'
          callback err
      ]
    , done

  after clear

describe 'Team#ReadByInviteCode', ->

  before prepare

  it 'should read team infomation by invite code', (done) ->
    options =
      method: 'GET'
      url: "/teams/readbyinvitecode"
      qs: inviteCode: app.team1.inviteCode
    request options, (err, res, team) ->
      team.should.have.properties 'name'
      done err

  after clear

describe 'Team#filterSensitiveWords', ->

  before prepare

  it "should not have phoneForLogin and mobile fields when user's hideMobile attribute is true on join action", (done) ->
    async.auto
      createNewUser: (callback) ->
        user = new UserModel
          name: 'user3'
          emailForLogin: "user3@jianliao.com"
          mobile: "13777777777"
          phoneForLogin: "13777777777"
        user.save (err, user) ->
          app.user3 = user
          callback err

      createNewMember:['createNewUser',  (callback) ->
        member = new MemberModel
          team: app.team1._id
          user: app.user3._id
          prefs:
            alias: "member1"
            isMute: false
            hideMobile: true
        member.save (err, member) ->
          app.member1 = member
          callback err
      ]

      join: ['createNewMember', (callback) ->

        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/join"
          body: JSON.stringify
            _sessionUserId: app.user3._id
            signCode: app.team1.signCode
        request options, (err, res, team) ->

          members = team.members

          members.forEach (user) ->

            if user._id is app.user3._id.toString()
              user.prefs.hideMobile.should.equal true
              user.should.not.have.properties 'mobile', 'phoneForLogin'
            else if "#{user._id}" is "#{app.user1._id}"
              user.prefs?.hideMobile.should.equal false
              user.should.have.properties 'phoneForLogin'

          callback err
      ]
    , done

  it 'should remove phoneForLogin and mobile attributes from member by default', (done) ->
    options =
      method: 'GET'
      url: "teams/#{app.team1._id}/members"
      body:
        _sessionUserId: app.user1._id
    request options, (err, res, members) ->

      members.forEach (user) ->

        if user._id is app.user3._id.toString()
          user.prefs.hideMobile.should.equal true
          user.should.not.have.properties 'mobile', 'phoneForLogin'
        else if "#{user._id}" is "#{app.user1._id}"
          user.prefs?.hideMobile.should.equal false
          user.should.have.properties 'phoneForLogin'

      done(err)

  it "should not have phoneForLogin and mobile fields when user's hideMobile attribute is true on 'readOne' action", (done) ->
    options =
      method: 'GET'
      url: "teams/#{app.team1._id}"
      qs: _sessionUserId: app.user1._id
    request options, (err, res, team) ->

      members = team.members

      members.forEach (user) ->

        if user._id is app.user3._id.toString()
          user.prefs.hideMobile.should.equal true
          user.should.not.have.properties 'mobile', 'phoneForLogin'
        else if "#{user._id}" is "#{app.user1._id}"
          user.prefs?.hideMobile.should.equal false
          user.should.have.properties 'phoneForLogin'

      done(err)

  after clear

describe 'Team#InviteNonExisentUser', ->

  before prepare

  it 'should send invite link when inviting a non-existent user', (done) ->
    email = 'jianliao@teambition.com'
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'invitation:create'
            data.should.have.properties '_teamId'
            data.should.not.have.properties '_roomId'
            data.name.should.eql 'jianliao'
            data.email.should.eql email
            callback()
      invite: (callback) ->
        options =
          method: 'POST'
          url: "teams/#{app.team1._id}/invite"
          body:
            _sessionUserId: app.user1._id
            email: email
        request options, (err, res, invitation) ->
          invitation.should.have.properties 'name', 'role', 'isInvite'
          callback err
      mailer: (callback) ->
        app.mailer = (email) ->
          {redirectUrl} = email
          redirectUrl.should.containEql "page/invite/#{app.team1.inviteCode}"
          callback()
    , done

  after clear
