async = require 'async'
app = require './app'
# Start fake servers
require './servers'

######################## Intialize ########################

app.fakeServer()

######################## Units ########################
require './util/util.coffee'

######################## Units ########################
require './schemas/message.coffee'
require './schemas/story.coffee'

######################## Apis ########################
require './controllers/discover.coffee'
require './controllers/user.coffee'
require './controllers/preference.coffee'
require './controllers/team.coffee'
require './controllers/room.coffee'
require './controllers/message.coffee'
require './controllers/favorite.coffee'
require './controllers/recommend.coffee'
require './controllers/integration.coffee'
require './controllers/devicetoken.coffee'
require './controllers/tag.coffee'
require './controllers/story.coffee'
require './controllers/notification.coffee'
require './controllers/discover.coffee'
require './controllers/invitation.coffee'
require './controllers/group.coffee'
require './controllers/usage.coffee'
require './controllers/activity.coffee'

######################## Services ########################
require './services/loader.coffee'
require './services/robot.coffee'
require './services/outgoing.coffee'
require './services/talkai.coffee'

describe 'Server#After', ->
  it 'should flush all database', ->
  after (done) ->
    app = require './app'
    async.auto
      clearDb: app.clearDb
      clearTmp: app.clearTmp
      flushdb: app.flushdb
    , done
