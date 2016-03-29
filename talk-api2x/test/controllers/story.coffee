should = require 'should'
async = require 'async'
Promise = require 'bluebird'
app = require '../app'
limbo = require 'limbo'
{prepare, prepareAsync, cleanup, request, requestAsync} = app

{
  StoryModel
  NotificationModel
} = limbo.use 'talk'

describe 'Story#CURD', ->

  before prepare

  it 'should create a private story with file and involve user2', (done) ->
    fileData =
      fileKey: '2107ff00571d2cf89eebbd0ddabbdeb38fb0'
      fileName: 'ic_favorite_task.png'
      fileType: 'png'
      fileSize: 2986
      fileCategory: 'image'
      other: 'unnecessary property'

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'story:create'
            hits |= 0b1
            channel.should.containEql "user:#{app.user1._id}"
            channel.should.containEql "user:#{app.user2._id}"
            data.category.should.eql 'file'
            data.data.should.have.properties 'downloadUrl', 'fileKey'
            data.data.should.not.have.properties 'other'
            data.members.length.should.eql 2
            data._memberIds.should.containEql "#{app.user1._id}"
            data._memberIds.should.containEql "#{app.user2._id}"
            app.story1 = data
          if event is 'notification:update'
            hits |= 0b10
            data.type.should.eql 'story'
            data.text.should.containEql '{{__info-create-story}}'
          resolve() if hits is 0b11
        catch err
          reject err

    $story = Promise.resolve().then ->
      options =
        method: 'POST'
        url: '/stories'
        body:
          _teamId: app.team1._id
          _sessionUserId: app.user1._id
          category: 'file'
          data: fileData
          _memberIds: [
            app.user2._id
          ]
      requestAsync options
      .spread (res, story) ->
        app._dataId = story.data._id
        story

    Promise.all [$broadcast, $story]
    .nodeify done

  it 'should read a story', (done) ->
    options =
      method: 'GET'
      url: "/stories/#{app.story1._id}"
      qs: _sessionUserId: app.user2._id
    request options, (err, res, story) ->
      story.should.have.properties 'creator', 'members'
      # Populated creator and members
      story.members.length.should.eql 2
      story.members.forEach (member) -> member.should.have.properties 'name'
      done err

  it 'should read a list of stories', (done) ->
    options =
      method: 'GET'
      url: "/stories"
      qs:
        _sessionUserId: app.user2._id
        _teamId: app.team1._id
    request options, (err, res, stories) ->
      stories.length.should.above 0
      stories.forEach (story) ->
        story.should.have.properties 'creator', 'members'
        # Populated creator and members
        story.members.length.should.eql 2
        story.members.forEach (member) -> member.should.have.properties 'name'
      done err

  it 'should update a story', (done) ->
    newFileData =
      fileKey: '2107ff00571d2cf89eebbd0ddabbdeb38fb0'
      fileName: 'new_filename.png'
      fileType: 'png'
      fileSize: 2986
      fileCategory: 'image'
      other: 'unnecessary property'

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        if event is 'story:update'
          hits |= 0b1
          data.data.should.have.properties 'downloadUrl'
          data.data.fileName.should.eql 'new_filename.png'
          # Should not change other fields
          data._memberIds.length.should.eql 2
          # Do not update unprovided fields of data
          "#{data.data._id}".should.eql "#{app._dataId}"
        if event is 'message:create'
          hits |= 0b10
          data.body.should.eql '{{__info-update-story}} new_filename.png'
        resolve() if hits is 0b11

    $updateStory = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "/stories/#{app.story1._id}"
        body:
          _sessionUserId: app.user1._id
          data: newFileData
      requestAsync options

    Promise.all [$broadcast, $updateStory]
    .nodeify done

  it 'should remove a story', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'story:remove'
            hits |= 0b1
          if event is 'notification:remove'
            hits |= 0b10
          resolve() if hits is 0b11
        catch err
          reject err

    $removeStory = Promise.resolve().then ->
      options =
        method: 'DELETE'
        url: "/stories/#{app.story1._id}"
        body:
          _sessionUserId: app.user1._id
      requestAsync options

    Promise.all [$broadcast, $removeStory]
    .nodeify done

  after cleanup

describe 'Story#Members', ->

  before (done) ->
    $prepare = prepareAsync()

    $story = $prepare.then ->
      story = new StoryModel
        creator: app.user1._id
        team: app.team1._id
        category: 'file'
        data:
          fileKey: '1107ff00571d2cf89eebbd0ddabbdeb38fb0'
          fileName: 'ic_favorite_task.png'
          fileType: 'png'
          fileSize: 2986
          fileCategory: 'image'
      app.story1 = story
      story.$save()

    $story.nodeify done

  it 'should add user to story1', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'story:update'
            hits |= 0b1
            data.members.length.should.eql 2
            data.members.forEach (member) -> member.should.have.properties 'name'
          if event is 'notification:update'
            hits |= 0b10
            data.text.should.eql '{{__info-invite-members}} dajiangyou2'
          if event is 'message:create'
            hits |= 0b100
            data.body.should.eql '{{__info-invite-members}} dajiangyou2'
          resolve() if hits is 0b111
        catch err
          reject err

    $addMembers = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "/stories/#{app.story1._id}"
        body:
          _sessionUserId: app.user1._id
          addMembers: [app.user2._id]
      requestAsync options

    Promise.all [$broadcast, $addMembers]

    .nodeify done

  it 'should remove user from story1', (done) ->
    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          if event is 'story:update'
            hits |= 0b1
            data.members.length.should.eql 1
            data.members.forEach (member) -> member.should.have.properties 'name'
          if event is 'notification:update'
            hits |= 0b10
            "#{data._teamId}".should.eql "#{app.team1._id}"
          if event is 'message:create'
            hits |= 0b100
            data.body.should.eql "{{__info-remove-members}} dajiangyou2"
          resolve() if hits is 0b111
        catch err
          reject err

    $removeMembers = Promise.resolve().then ->
      options =
        method: 'PUT'
        url: "/stories/#{app.story1._id}"
        body:
          _sessionUserId: app.user1._id
          removeMembers: [app.user2._id]
      requestAsync options

    Promise.all [$broadcast, $removeMembers]

    .nodeify done

  after cleanup

describe 'Story#Link', ->

  before prepare

  it 'should create a link typed story and get url metas from link address', (done) ->

    $broadcast = new Promise (resolve, reject) ->
      hits = 0
      app.broadcast = (channel, event, data) ->
        try
          # Create new story without title
          if event is 'story:create'
            hits |= 0b1
            data.category.should.eql 'link'
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
          category: 'link'
          data: url: 'http://t.cn/Rz3I0cX'
      app.requestAsync options

    Promise.all [$createStory, $broadcast]

    .nodeify done

  after cleanup
