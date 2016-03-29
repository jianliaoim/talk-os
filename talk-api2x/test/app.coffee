fs = require 'fs'
path = require 'path'

async = require 'async'
Promise = require 'bluebird'
uuid = require 'uuid'
_ = require 'lodash'
Promise = require 'bluebird'
request = require 'supertest'
express = require 'express'
Sundae = require 'sundae'

{limbo, redis, socket} = require '../server/components'
db = limbo.use 'talk'
config = require 'config'
util = require '../server/util'

{
  TeamModel
  RoomModel
  MessageModel
  UserModel
  MemberModel
  StoryModel
} = db

app = {}
# test session user id in teambition db
app.token = 'fasdfasdfasdfasdfasdf'
app.limbo = limbo
app.redis = redis
app.broadcast = ->
app.mailer = ->
app._app = express()

app.fakeServer = ->
  ## Intialize server
  redis.select 3
  app._app = require '../server/server'

  service = require '../server/service'

  app.fakeMailer()
  app.fakeSocket()

app.fakeMailer = ->
  BaseMailer = require '../server/mailers/base'
  BaseMailer.prototype._send = (email, callback = ->) ->
    app.mailer email
    # return callback()  # Do not write tmp file
    fs.writeFile path.join(__dirname, '../tmp/', @template) + '.html'
    , email.html, callback

app.fakeSocket = ->
  socket.broadcast = (room, event, data, socketId) ->
    data = JSON.parse(JSON.stringify(data))
    app.broadcast room, event, data, socketId

################ util ################
app.clearDb = (callback = ->) ->
  {collections} = db._conn
  async.each Object.keys(collections), (collection, next) ->
    db._conn.collections[collection].remove({isRobot: {$ne: true}}, next)
  , callback

app.request = (options, callback = ->) ->
  method = options.method?.toLowerCase() or 'get'
  options.body = JSON.stringify(options.body) if toString.call(options.body) is '[object Object]'
  options.headers = _.extend
    "Content-Type": "application/json"
  , options.headers or {}
  request(app._app)[method] '/' + path.join(config.apiVersion, options.url)
  .set(options.headers)
  .send options.body or options.qs or {}
  .end (err, res) ->
    {res, body} = res
    if res?.statusCode > 399
      err or= new Error(body.message)
    callback(err, res, body)

app.flushdb = (callback = ->) ->
  redis.flushdb(callback)

app.clearTmp = (callback = ->) ->
  return callback()
  tmpDir = path.join(__dirname, '../tmp')
  fs.readdir tmpDir, (err, files) ->
    async.each files, (file, next) ->
      fs.unlink path.join(tmpDir, file), next
    , callback

app.clear = (callback = ->) ->
  app.broadcast = ->
  app.mailer = ->
  async.auto
    clearDb: app.clearDb
  , callback

app.cleanup = app.clear

################ util ################

################ data ################
app.createUsers = (callback) ->
  async.each [1, 2], (num, next) ->
    db.user.create
      name: "dajiangyou#{num}"
      avatarUrl: 'null'
      emailForLogin: "user#{num}@teambition.com"
      phoneForLogin: "1338888888#{num}"
      role: 'admin'
    , (err, user) ->
      app["user#{num}"] = JSON.parse(JSON.stringify(user))
      next()
  , callback

app.createTeams = (callback) ->
  async.each [1, 2], (num, next) ->
    async.waterfall [
      (next) ->
        team = new TeamModel
          name: "team#{num}"
          description: "team #{num}'s description"
          creator: app.user1._id
        team.save (err, team) -> next err, team
      (team, next) ->
        if num is 1
          team.addMember app.user2._id, (err) ->
            next err, team
        else
          next null, team
      (team, next) ->
        app["team#{num}"] = JSON.parse(JSON.stringify(team))
        next null, team
    ], next
  , callback

app.createRooms = (callback) ->
  async.each [1, 2], (num, next) ->
    async.waterfall [
      (next) ->
        room = new RoomModel
          team: app["team#{num}"]._id
          topic: "room#{num}"
          creator: app.user1._id
          guestToken: uuid.v1().split('-')[0]
          isGuestVisible: false
        room.save (err, room) ->
          next err, room
      (room, next) ->
        if num is 1
          room.addMember app.user2._id, (err) ->
            next err, room
        else
          next null, room
      (room, next) ->
        app["room#{num}"] = JSON.parse(JSON.stringify(room))
        next null, room
    ], next
  , callback

app.createStory = (callback) ->
  story = new StoryModel
    team: app.team1._id
    creator: app.user1._id
    category: 'topic'
    data:
      title: 'TITLE'
      text: 'text'
    members: [app.user1._id]
  story.$save().then (story) ->
    app.story1 = story
  .nodeify callback

################ data ################

################ alias ################
app.createIntegration = (callback) ->
  db.integration.create
    creator: app.user1._id
    team: app.team1._id
    room: app.room1._id
    category: 'weibo'
    token: app.token
    showname: 'Teambition开发者'
    notifications: mention: 1, comment: 1
  , (err, integration) ->
    app.integration = JSON.parse(JSON.stringify(integration))
    callback()

app.createGuestUser = (callback) ->
  db.user.create
    name: 'guest1'
    email: 'guest1@somedomain.com'
    avatarUrl: 'http://ok.com'
    source: 'talk'
    isGuest: true
  , (err, user) ->
    app.guest1 = JSON.parse(JSON.stringify(user))
    callback err

app.createUser3 = (callback) ->
  user = new UserModel
    name: '路人甲'
    emailForLogin: 'lurenjia@teambition.com'
  user.save (err, user) ->
    app.user3 = JSON.parse(JSON.stringify(user))
    callback err, user
################ alias ################

app.prepare = (done) ->
  async.auto
    initData: (callback) ->
      async.series [
        app.createUsers
        app.createTeams
        app.createRooms
      ], callback
  , done

module.exports = app

Promise.promisifyAll app
