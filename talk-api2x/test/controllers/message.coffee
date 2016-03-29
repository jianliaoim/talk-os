should = require 'should'
async = require 'async'
limbo = require 'limbo'
Promise = require 'bluebird'

app = require '../app'
{prepare, cleanup, request, requestAsync} = app
util = require '../../server/util'

{
  MessageModel
  MemberModel
  StoryModel
  UserModel
  TagModel
} = limbo.use 'talk'

_prepare = (done) ->
  async.series [
    app.createUsers
    app.createTeams
    app.createRooms
  ], done

_createMessage = (done) ->
  async.auto
    prepare: prepare
    createMessage: ['prepare', (callback) ->
      MessageModel.create
        creator: app.user1._id
        room: app.room1._id
        team: app.team1._id
        body: 'hello'
      , (err, message) ->
        app.message1 = JSON.parse(JSON.stringify(message))
        callback err
    ]
  , done

describe 'Message#Create', ->

  before _prepare

  it 'should create message to the room', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (room, event, data) ->
          if event is 'message:create'
            hits |= 0b1
            data.should.have.properties 'body', '_roomId', '_creatorId', 'notification'
            data._roomId.should.eql app.room1._id
            data._creatorId.should.eql app.user2._id
            data.room.should.have.properties 'topic'
            data.creator.should.have.properties 'name'
            data.room.prefs.should.have.properties 'isMute'
          if event is 'notification:update' and data.unreadNum is 1
            hits |= 0b10
            data.should.have.properties 'text', 'target'
            "#{data.target._id}".should.eql "#{app.room1._id}"
            "#{data.creator._id}".should.eql "#{app.user2._id}"
            data.text.should.containEql 'hello'
          callback() if hits is 0b11
      create: (callback) ->
        options =
          method: 'post'
          url: 'messages'
          body:
            _sessionUserId: app.user2._id
            _roomId: app.room1._id
            body: "message <$at|#{app.user1._id}|@dajiangyou1$> hello"
        request options, (err, res, message) ->
          message.should.have.properties 'body', '_roomId', '_creatorId'
          message._roomId.should.eql app.room1._id
          message._creatorId.should.eql app.user2._id
          message._teamId.should.eql app.team1._id
          callback err
      mailer: (callback) ->
        app.mailer = (email) ->
          {messages} = email
          messages.length.should.above 0
          (messages.some (message) ->
            message.getAlert().indexOf('message @dajiangyou1 hello') > -1
          ).should.eql true
          callback()
    , done

  it 'should create message to user1', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (room, event, data) ->
          if event is 'message:create'
            hits |= 0b1
            data.should.have.properties 'body', '_toId', '_teamId', 'notification'
            data._toId.should.eql app.user1._id
            data._teamId.should.eql app.team1._id
            data.creator.should.have.properties 'name', 'email'
            data.to.should.have.properties 'name', 'email'
          if event is 'notification:update' and "#{data._userId}" is "#{app.user1._id}"
            hits |= 0b10
            data.should.have.properties 'text', 'target'
            "#{data.target._id}".should.eql "#{app.user2._id}"
            "#{data.creator._id}".should.eql "#{app.user2._id}"
            data.text.should.containEql 'message 1'
            data.unreadNum.should.eql 1
          callback() if hits is 0b11
      create: (callback) ->
        options =
          method: 'post'
          url: 'messages'
          body: JSON.stringify
            _sessionUserId: app.user2._id
            _toId: app.user1._id
            _teamId: app.team1._id
            body: 'message 1'
        request options, (err, res, message) ->
          message.should.have.properties 'body', '_toId', '_creatorId', '_teamId'
          message._creatorId.should.eql app.user2._id
          message._toId.should.eql app.user1._id
          message._teamId.should.eql app.team1._id
          callback err
      mailer: (callback) ->
        app.mailer = (email) ->
          {messages} = email
          messages.length.should.above 0
          (messages.some (message) -> message.getAlert().indexOf('message 1') > -1).should.eql true
          callback()
    , done

  it 'should not create message to the non-member user3', (done) ->
    async.auto
      createUser3: (callback) ->
        UserModel.create
          name: 'dajiangyou3'
          avatarUrl: 'null'
        , (err, user) ->
          app.user3 = JSON.parse(JSON.stringify(user))
          callback(err)
      createMessage: ['createUser3', (callback) ->
        options =
          method: 'post'
          url: 'messages'
          body: JSON.stringify
            _sessionUserId: app.user1._id
            _toId: app.user3._id
            _teamId: app.team1._id
            body: 'message 1'
        request options, (err, res, errObj) ->
          errObj.code.should.eql(204)
          callback()
      ]
    , done

  it 'should auto fetch the web body of the url when the message contains url', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (room, event, message) ->
          if event is 'message:update'
            hits |= 0b1
            message.attachments.length.should.above 0
            message.attachments.forEach (attachment) ->
              {data, category} = attachment
              category.should.eql 'quote'
              data.should.have.properties 'category', 'title'
              data.category.should.eql 'url'
          callback() if hits is 0b1
      createMessage: (callback) ->
        options =
          method: 'post'
          url: 'messages'
          body: JSON.stringify
            _sessionUserId: app.user1._id
            _roomId: app.room1._id
            body: "hello http://t.cn/Rz3I0cX中文"
        request options, callback
    , done

  it 'should create a message with an speech audio', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (room, event, message) ->
          if event is 'message:create'
            hits |= 0b1
            message.attachments[0].category.should.eql 'speech'
            message.attachments[0].data.should.have.properties 'fileName', 'fileKey', 'downloadUrl', 'duration'
          callback() if hits is 0b1
      createMessage: (callback) ->
        options =
          method: 'POST'
          url: '/messages'
          body:
            _sessionUserId: app.user1._id
            _roomId: app.room1._id
            attachments: [
              category: 'speech'
              data:
                fileName: "abc.amr"
                fileKey: "1eeefa94bca582b54ad24fe3debe1558"
                fileType: "amr"
                duration: 100
            ]
        request options, callback
    , done

  it 'should create a calendar message and receive a message when trigger a calendar', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'message:create' and data.creator?.isRobot is true
            hits |= 0b1
            "#{data.body}".should.eql '<$at|all|@所有成员$> {{__info-discussion-started}} ok'
            "#{data._teamId}".should.eql "#{app.team1._id}"
            "#{data._roomId}".should.eql "#{app.room1._id}"
          resolve() if hits is 0b1
        catch err
          reject err

    $message = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _roomId: app.room1._id
          body: 'ok'
          attachments: [
            category: 'calendar'
            data:
              remindAt: Date.now() + 1000
          ]
      requestAsync options
      .spread (res) -> res.body

    $calendar = $message.then (message) ->
      calendarJob = require '../../server/jobs/calendar'
      calendarJob message._id

    Promise.all [$broadcast, $message, $calendar]
    .nodeify done

  after cleanup

describe 'Message#Read', ->

  _besideId = null

  before (done) ->
    async.auto
      prepare: _prepare
      createRoomMessages: ['prepare', (callback) ->
        async.eachSeries ['first', 'second', 'third'], (body, next) ->
          MessageModel.create
            room: app.room1._id
            team: app.team1._id
            creator: app.user1._id
            body: body
          , (err, message) ->
            _besideId = message._id if body is 'second'
            next err
        , callback
      ]
      createUserMessages: ['prepare', (callback) ->
        async.parallel [
          (next) ->
            async.eachSeries ['first', 'second'], (body, _next) ->
              MessageModel.create
                creator: app.user2._id
                to: app.user1._id
                body: body
                team: app.team1._id
              , _next
            , next
          (next) ->
            MessageModel.create
              creator: app.user1._id
              to: app.user2._id
              body: 'third'
              team: app.team1._id
            , next
        ], callback
      ]
    , done

  it 'should read the latestMessages messages from the room', (done) ->
    options =
      method: 'get'
      url: 'messages'
      qs:
        _sessionUserId: app.user1._id
        _roomId: app.room1._id
        limit: 3
    request options, (err, res, messages) ->
      messages.length.should.eql(3)
      messages.forEach (message) ->
        message.should.have.properties 'body', '_roomId', '_creatorId'
      done err

  it 'should read the messages between user1 and user2', (done) ->
    options =
      method: 'get'
      url: 'messages'
      qs:
        _sessionUserId: app.user1._id
        _withId: app.user2._id
        _teamId: app.team1._id
    request options, (err, res, messages) ->
      messages.length.should.eql(3)
      messages.forEach (message) ->
        message.should.have.properties 'body', '_toId', '_teamId', '_creatorId'
      done err

  it 'should read messages with a special category', (done) ->
    async.auto
      createSpeechMessage: (callback) ->
        options =
          method: 'POST'
          url: '/messages'
          body: JSON.stringify
            _sessionUserId: app.user1._id
            _roomId: app.room1._id
            attachments: [
              category: 'speech'
              data:
                fileName: "abc.amr"
                fileKey: "1eeefa94bca582b54ad24fe3debe1558"
                fileType: "amr"
                duration: 100
            ]
        request options, callback
      readSpeechMessage: ['createSpeechMessage', (callback) ->
        options =
          method: 'get'
          url: 'messages'
          qs:
            _sessionUserId: app.user1._id
            _roomId: app.room1._id
            category: 'speech'
        request options, (err, res, messages) ->
          messages.length.should.eql 1
          messages.forEach (message) ->
            message.attachments[0].category.should.eql 'speech'
          callback err
      ]
    , done

  it 'should read messages beside _id', (done) ->
    options =
      method: 'GET'
      url: '/messages'
      qs:
        _sessionUserId: app.user1._id
        _roomId: app.room1._id
        _besideId: _besideId
        limit: 1
    request options, (err, res, messages) ->
      messages.length.should.eql 2
      messages.forEach (message) ->
        ['first', 'second', 'third'].should.containEql message.body
      done err

  after cleanup

describe 'Message#Update', ->

  before _createMessage

  it 'should update the message by id', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'message:update'
            if data._id is app.message1._id
              data.creator.should.have.properties 'name', 'email'
              data.room.should.have.properties 'topic'
              data.body.should.eql 'to be'
              callback()
      updateMessage: (callback) ->
        options =
          method: 'PUT'
          url: "messages/#{app.message1._id}"
          body:
            _sessionUserId: app.user1._id
            body: 'to be'
        request options, callback
    , done

  it 'should mark a message has receipted by others', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'message:update'
            data.receiptors.length.should.eql 1
            "#{data.receiptors[0]}".should.eql app.user2._id
            hits |= 0b1
          resolve() if hits is 0b1
        catch err
          reject err

    $readMessage = Promise.resolve().then ->
      options =
        method: 'POST'
        url: "/messages/#{app.message1._id}/receipt"
        body: _sessionUserId: app.user2._id
      requestAsync options

    Promise.all [$broadcast, $readMessage]
    .nodeify done

  after cleanup

describe 'Message#Remove', ->

  before _createMessage

  it 'should delete message by id', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (room, event, data) ->
        try
          if event is 'message:remove'
            hits |= 0b1
            data._id.should.eql app.message1._id
          if event is 'notification:update' and data.text.indexOf('{{__info-remove-message}}') > -1
            hits |= 0b10
            "#{data._creatorId}".should.eql "#{app.user1._id}"
          resolve() if hits is 0b11
        catch err
          reject err

    # Waiting for create new notification
    $deleteMessage = Promise.delay(100).then ->
      options =
        method: 'DELETE'
        url: "messages/#{app.message1._id}"
        body: _sessionUserId: app.user1._id
      requestAsync options

    Promise.all [$broadcast, $deleteMessage]
    .nodeify done

  after cleanup

describe 'Message#Clear', ->

  before prepare

  it 'should cleanup the unread message num when call the cleanup method', (done) ->
    message = {}
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (room, event, data) ->
          if event is 'message:unread'
            hits |= 0b1
            data.should.have.properties '_teamId', 'unread', "_latestReadMessageId"
            data._latestReadMessageId[app.room1._id].should.eql "#{message._id}"
          if event is 'notification:update'
            "#{data.target._id}".should.eql app.room1._id
            if data.unreadNum is 1
              # Create message
              hits |= 0b10
            else if data.unreadNum is 0
              # Cleanup message unread number
              hits |= 0b100
              "#{data._latestReadMessageId}".should.eql "#{message._id}"
            else throw new Error('Unexpected notification unread number', notification)
          callback() if hits is 0b111
      create: (callback) ->
        options =
          method: 'post'
          url: 'messages'
          body: JSON.stringify
            _roomId: app.room1._id
            _sessionUserId: app.user2._id
            message: 'hello'
        request options, (err, res, _message) ->
          message = _message
          callback err
      cleanup: ['create', (callback) ->
        options =
          method: 'post'
          url: '/messages/clear'
          body: JSON.stringify
            _roomId: app.room1._id
            _sessionUserId: app.user1._id
            _latestReadMessageId: message._id
        request options, (err, res, result) ->
          result.ok.should.eql(1)
          callback err
      ]
    , done

  after cleanup

describe 'Message#Tags', ->

  before _createMessage

  it 'should update tags of a message', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (channel, event, data) ->
          if event is 'message:update'
            hits |= 0b1
            # Two people in this room
            data.tags.length.should.eql 1
            data.tags[0].name.should.eql '测试'
          return callback() if hits is 0b1
      createTag: (callback) ->
        options =
          method: 'POST'
          url: '/tags'
          body:
            _teamId: app.team1._id
            name: '测试'
            _sessionUserId: app.user1._id
        app.request options, (err, res, tag) ->
          app.tag1 = tag
          callback()
      updateMessage: ['createTag', (callback) ->
        options =
          method: 'PUT'
          url: "/messages/#{app.message1._id}"
          body:
            _tagIds: [app.tag1._id]
            _sessionUserId: app.user2._id
        app.request options, callback
      ]
    , done

  it 'should read the messages by tag id', (done) ->
    async.auto
      readMessages: (callback) ->
        options =
          method: 'GET'
          url: '/messages'
          qs:
            _teamId: app.team1._id
            _roomId: app.room1._id
            _tagId: app.tag1._id
            _sessionUserId: app.user1._id
        app.request options, (err, res, messages) ->
          messages.length.should.eql 1
          messages[0].tags.length.should.eql 1
          messages[0].tags[0].name.should.eql "测试"
          callback err
    , done

  it 'should remove tag id from message when remove tag', (done) ->
    async.auto
      removeTag: (callback) ->
        options =
          method: 'DELETE'
          url: "/tags/#{app.tag1._id}"
          body: _sessionUserId: app.user1._id
        app.request options, callback
      readMessage: ['removeTag', (callback) ->
        options =
          method: 'GET'
          url: "/messages"
          qs:
            _teamId: app.team1._id
            _roomId: app.room1._id
            _tagId: app.tag1._id
            _sessionUserId: app.user1._id
        app.request options, (err, res, messages) ->
          messages.length.should.eql 0
          callback err
      ]
    , done

  after cleanup

describe 'Message#Repost(s)', ->

  before _createMessage

  it 'should repost message to another room', (done) ->

    _checkMessage = (message) ->
      message._creatorId.should.eql app.user2._id
      message.body.should.eql 'hello'
      "#{message._toId}".should.eql "#{app.user1._id}"
      "#{message._id}".should.not.eql app.message1._id
      "#{message.createdAt}".should.not.eql "#{app.message1.createdAt}"
      message.should.not.have.properties '_roomId'

    async.auto
      updateRoomMember: (callback) ->
        MemberModel.findOneAndUpdate
          user: app.user2._id
          room: app.room2._id
        ,
          isQuit: false
        ,
          upsert: true
        , callback
      repost: ['updateRoomMember', (callback) ->
        options =
          method: 'POST'
          url: "/messages/#{app.message1._id}/repost"
          body:
            _toId: app.user1._id
            _teamId: app.team1._id
            _sessionUserId: app.user2._id
        app.request options, (err, res, message) ->
          _checkMessage message
          callback err
      ]
      reposts: ['updateRoomMember', (callback) ->
        options =
          method: 'POST'
          url: "/messages/reposts"
          body:
            _messageIds: [app.message1._id]
            _toId: app.user1._id
            _teamId: app.team1._id
            _sessionUserId: app.user2._id
        app.request options, (err, res, messages) ->
          messages.length.should.eql 1
          messages.forEach _checkMessage
          callback err
      ]
    , done

  it 'should repost message to another team', (done) ->

    $repost = Promise.resolve().then ->
      options =
        method: 'POST'
        url: "/messages/#{app.message1._id}/repost"
        body:
          _roomId: app.room2._id
          _sessionUserId: app.user1._id
      requestAsync options

    .spread (res) ->
      message = res.body
      "#{message._teamId}".should.eql "#{app.team2._id}"
      "#{message._roomId}".should.eql "#{app.room2._id}"
      message.body.should.eql app.message1.body

    Promise.all [$repost]
    .nodeify done

  after cleanup

describe 'Message#Story', ->

  before _prepare

  it 'should create a message to a story', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'message:create'
            hits |= 0b1
            data.should.have.properties 'body', '_storyId', 'story', '_teamId'
            data.should.not.have.properties 'room', '_roomId', 'to', '_toId'
            data.story.should.have.properties 'category', 'data', 'members'
          resolve() if hits is 0b1
        catch err
          reject err

    $story = Promise.resolve().then ->
      story = new StoryModel
        creator: app.user1._id
        team: app.team1._id
        category: 'topic'
        data:
          content: 'content'
        _memberIds: [app.user2._id]
      app.story1 = story
      story.$save()

    $message = $story.then (story) ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user2._id
          _storyId: story._id
          body: "ok"
      requestAsync options

    Promise.all [$broadcast, $story, $message]

    .nodeify done

  it 'should read messages by _storyId', (done) ->
    options =
      method: 'GET'
      url: '/messages'
      qs:
        _sessionUserId: app.user1._id
        _storyId: app.story1._id
    request options, (err, res, messages) ->
      messages.length.should.above 0
      messages.forEach (message) ->
        message.should.have.properties '_storyId', 'story'
      done err

  after cleanup

describe 'Message#AddProperty', ->

  before _prepare

  it 'should create message with displayType and be equal to assigned value', (done) ->
    async.auto
      create: (callback) ->
        options =
          method: 'post'
          url: 'messages'
          body:
            _sessionUserId: app.user2._id
            _roomId: app.room1._id
            body: "message <$at|#{app.user1._id}|@dajiangyou1$> hello"
            displayType : 'markdown'
        request options, (err, res, message) ->
          message.should.have.properties 'body', '_roomId', '_creatorId', 'displayType'
          message._roomId.should.eql app.room1._id
          message._creatorId.should.eql app.user2._id
          message._teamId.should.eql app.team1._id
          message.displayType.should.eql 'markdown'
          callback err
    , done

  after cleanup

describe 'Message#AddPosProperty', ->

  before prepare

  it 'should create a message with mark property', (done) ->
    $story = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/stories'
        body:
          category: 'file'
          data:
            fileKey: '1107c714fa14c8b34aa01f82612a0141fc90'
            fileName: 'map.png'
            fileType: 'png'
            fileSize: 1031231
            fileCategory: 'image'
            imageWidth: 1920
            imageHeight: 1080
          _teamId: app.team1._id
          _sessionUserId: app.user1._id
      requestAsync(options).spread (res, story) ->
        app.story1 = story
        story

    # Create first message
    $message1 = $story.then (story) ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _storyId: story._id
          body: "First message on mark 1"
          mark: x: 1000, y: 1000
      requestAsync(options).spread (res, message1) ->
        app.message1 = message1
        message1.mark.should.have.properties 'team', 'target', 'type', 'creator', 'text', '_creatorId'
        message1.mark.text.should.eql message1.body
        message1

    # Create second message with the same mark of message 1
    $message2 = Promise.all [$story, $message1]

    .spread (story, message1) ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _sessionUserId: app.user1._id
          _storyId: story._id
          body: 'Second message on mark 1'
          mark: x: 1000, y: 1000
      requestAsync(options).spread (res, message2) ->
        "#{message2.mark._id}".should.eql "#{message1.mark._id}"
        app.message2 = message2
        app.mark1 = message2.mark

    Promise.all([$story, $message1, $message2]).nodeify done

  it 'should read the marks of story1', (done) ->
    $marks = Promise.resolve().then ->
      options =
        method: 'GET'
        url: '/marks'
        qs:
          _targetId: app.story1._id
          _sessionUserId: app.user1._id
      requestAsync(options).spread (res, marks) ->
        marks.length.should.eql 1
        marks.forEach (mark) -> mark.should.have.properties 'x', 'y'

    $marks.nodeify done

  it 'should read the messages of mark1', (done) ->
    $messages = Promise.resolve().then ->
      options =
        method: 'GET'
        url: '/messages'
        qs:
          _sessionUserId: app.user1._id
          _storyId: app.story1._id
          _markId: app.mark1._id
      requestAsync(options).spread (res, messages) ->
        messages.length.should.eql 2
        messages.forEach (message) -> message.should.have.properties 'mark'

    $messages.nodeify done

  it 'should remove mark1', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'mark:remove'
            hits |= 0b1
            data.should.have.properties 'x', 'y'
        catch err
          return reject(err)
        resolve() if hits is 0b1

    $remove = Promise.resolve().then ->
      options =
        method: 'DELETE'
        url: "/marks/#{app.mark1._id}"
        qs: _sessionUserId: app.user1._id
      requestAsync(options)

    # Read messages again
    $checkMessages = $remove.delay(200).then ->
      MessageModel.findAsync _id: $in: ["#{app.message1._id}", "#{app.message2._id}"]
      .then (messages) ->
        messages.length.should.eql 2
        messages.forEach (message) -> message.toJSON().should.not.have.properties 'mark'

    Promise.all([$broadcast, $remove, $checkMessages]).nodeify done

  after cleanup

describe 'Message#fetchUrlImg', ->

  before _prepare

  it 'should auto fetch the image of the url when the message contains url with image extension', (done) ->
    async.auto
      broadcast: (callback) ->
        hits = 0
        app.broadcast = (room, event, message) ->
          if event is 'message:update'
            hits |= 0b1
            message.attachments.length.should.above 0
            message.attachments.forEach (attachment) ->
              {data, category} = attachment
              category.should.eql 'file'
              data.should.have.properties 'fileKey', 'fileName', 'fileType'
          callback() if hits is 0b1
      createMessage: (callback) ->
        options =
          method: 'post'
          url: '/messages'
          body: JSON.stringify
            body: "http://127.0.0.1:7632/striker/thumbnail.png"
            _sessionUserId: app.user1._id
            _roomId: app.room1._id
        request options, callback
    , done
  after cleanup

describe 'Message#UpdateContentWithUrl', ->

  before _createMessage

  it 'should update the message with url content', (done) ->
    async.auto
      broadcast: (callback) ->
        app.broadcast = (room, event, data) ->
          if event is 'message:update'
            if data._id is app.message1._id
              data.body.should.eql 'http://127.0.0.1:7632/teambition/url/content'
              data.attachments.forEach (attachment)->
                attachmentData = attachment.data
                category = attachment.category
                category.should.eql 'quote'
                attachmentData.should.have.properties 'category', 'title'
                attachmentData.category.should.eql 'url'
                attachmentData.title.should.eql 'jianliao'
              callback()
      updateMessage: (callback) ->
        options =
          method: 'PUT'
          url: "messages/#{app.message1._id}"
          body:
            _sessionUserId: app.user1._id
            body: 'http://127.0.0.1:7632/teambition/url/content'
        request options, callback
    , done

  after cleanup

describe "Message#mentions", ->

  before (done) ->

    $prepare = app.prepareAsync()

    # Create messages with @
    $atUserMsg = $prepare.then ->
      options =
        method: 'post'
        url: 'messages'
        body:
          _sessionUserId: app.user2._id
          _roomId: app.room1._id
          body: "message <$at|#{app.user1._id}|@dajiangyou1$> hello"
      requestAsync options

    $atAllMsg = $atUserMsg.then ->
      options =
        method: 'post'
        url: 'messages'
        body:
          _sessionUserId: app.user2._id
          _roomId: app.room1._id
          body: "<$at|all|@所有成员$> hello"
      requestAsync options

    $normalMsg = $prepare.then ->
      options =
        method: 'post'
        url: 'messages'
        body:
          _sessionUserId: app.user2._id
          _roomId: app.room1._id
          body: "hello world"
      requestAsync options

    Promise.all [$atAllMsg, $normalMsg]

    .nodeify done

  it 'should return two ordered records for user1', (done) ->
    options =
      method: 'get'
      url: '/messages/mentions'
      qs:
        _sessionUserId: app.user1._id
        _teamId: app.team1._id
    request options, (err, res, messages) ->
      messages.length.should.eql(2)
      messages[0].body.should.eql "<$at|all|@所有成员$> hello"
      messages[1].body.should.eql "message <$at|#{app.user1._id}|@dajiangyou1$> hello"
      messages.forEach (message) ->
        message.should.have.properties 'body', '_roomId', '_creatorId', 'mentions'
      done err

  it 'should not return at all for user2', (done) ->
    options =
      method: 'get'
      url: '/messages/mentions'
      qs:
        _sessionUserId: app.user2._id
        _teamId: app.team1._id
    request options, (err, res, messages) ->
      messages.length.should.eql(0)
      done err

  it 'should return three records for normal read', (done) ->
    options =
      method: 'get'
      url: 'messages'
      qs:
        _sessionUserId: app.user1._id
        _roomId: app.room1._id
    request options, (err, res, messages) ->
      messages.length.should.eql(3)
      messages.forEach (message) ->
        message.should.have.properties 'body', '_roomId', '_creatorId', 'mentions'
      done err

  after cleanup

describe 'Message#tags', ->

  before (done) ->
    $prepare = app.prepareAsync()

    $tag = $prepare.then ->
      options =
        method: 'POST'
        url: '/tags'
        body:
          _teamId: app.team1._id
          name: 'ok'
          _sessionUserId: app.user1._id
      requestAsync options
      .spread (res) -> app.tag1 = res.body

    $message = $tag.then ->
      options =
        method: 'POST'
        url: '/messages'
        body:
          _roomId: app.room1._id
          body: 'hello'
          _sessionUserId: app.user1._id
      requestAsync options
      .spread (res) -> res.body

    $addTag = Promise.all [$tag, $message]
    .spread (tag, message) ->
      options =
        method: 'PUT'
        url: "/messages/#{message._id}"
        body:
          _sessionUserId: app.user1._id
          _tagIds: [tag._id]
      requestAsync options
      .spread (res) -> app.message1 = res.body

    $addTag.nodeify done

  it 'should read all the messages with tag', (done) ->

    options =
      method: 'GET'
      url: '/messages/tags'
      qs:
        _sessionUserId: app.user1._id
        _teamId: app.team1._id

    request options, (err, res) ->
      res.body.length.should.eql 1
      done err

  it 'should read messages by the given _tagId', (done) ->

    options =
      method: 'GET'
      url: '/messages/tags'
      qs:
        _sessionUserId: app.user1._id
        _teamId: app.team1._id
        _tagId: app.tag1._id

    request options, (err, res) ->
      res.body.length.should.eql 1
      done err

  after cleanup
