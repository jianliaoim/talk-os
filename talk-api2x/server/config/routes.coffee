###
jianliao.com route configs
###
path = require 'path'
Err = require 'err1st'
config = require 'config'

app = require '../server'
auth = require '../middlewares/auth'
authGuest = require '../middlewares/auth-guest'

app.middlewares = [auth()] unless config.test

app.get '/t/:shortName', to: 'discover#toTeam'

app.routePrefix = '/'

app.routeCallback = (req, res) -> res.response()

# ----------- message --------------
app.post '/messages/clear', to: 'message#clear'

app.get '/messages/search', to: 'message#search'

app.post '/messages/search', to: 'message#search'

app.post '/messages/:_id/repost', to: 'message#repost'

app.post '/messages/:_id/receipt', to: 'message#receipt'

app.post '/messages/reposts', to: 'message#reposts'

app.get '/messages/mentions', to: 'message#mentions'

app.get '/messages/tags', to: 'message#tags'

app.resource 'message', only: ['create', 'read', 'update', 'remove']
# ----------- message --------------

# ----------- favorites --------------
app.get '/favorites/search', to: 'favorite#search'

app.post '/favorites/search', to: 'favorite#search'

app.post '/favorites/batchRemove', to: 'favorite#batchRemove'

app.post '/favorites/:_id/repost', to: 'favorite#repost'

app.post '/favorites/reposts', to: 'favorite#reposts'

app.resource 'favorite', only: ['create', 'read', 'remove']
# ----------- favorites --------------

# ----------- user --------------
app.post '/users/signout', to: 'user#signout'

app.post '/users/subscribe', to: 'user#subscribe'

app.post '/users/unsubscribe', to: 'user#unsubscribe'

app.post '/users/checkin', to: 'user#checkin'

app.get '/users/me', to: 'user#me'

app.get '/via/:inviteCode', to: 'user#via', middlewares: []

app.get '/users/landing', to: 'user#landing'

app.get '/union/:refer/landing', to: 'user#landing'

app.resource 'user', only: ['read', 'readOne', 'update']
# ----------- user --------------

# ----------- preference --------------
app.get '/preferences', to: 'preference#readOne'

app.put '/preferences', to: 'preference#update'
# ----------- preference --------------

# ----------- invitation --------------

app.resource 'invitation', only: ['remove', 'read']

# ----------- invitation --------------

# ----------- team --------------
app.post '/teams/syncone', to: 'team#syncOne'

app.post '/teams/sync', to: 'team#sync'

app.get '/teams/thirds', to: 'team#thirds'

app.get '/teams/:_id/rooms', to: 'team#rooms'

app.get '/teams/:_id/members', to: 'team#members'

app.get '/teams/:_id/latestmessages', to: 'team#latestMessages'

app.post '/teams/:_id/joinbysigncode', to: 'team#joinBySignCode'

app.post '/teams/:_id/join', to: 'team#join'

app.post '/teams/:_id/leave', to: 'team#leave'

app.post '/teams/:_id/subscribe', to: 'team#subscribe'

app.post '/teams/:_id/unsubscribe', to: 'team#unsubscribe'

app.post '/teams/:_id/invite', to: 'team#invite'

app.post '/teams/:_id/batchinvite', to: 'team#batchInvite'

app.post '/teams/:_id/removemember', to: 'team#removeMember'

app.post '/teams/:_id/setmemberrole', to: 'team#setMemberRole'

app.post '/teams/:_id/pin/:_targetId', to: 'team#pinTarget'

app.post '/teams/:_id/unpin/:_targetId', to: 'team#unpinTarget'

app.post '/teams/:_id/refresh', to: 'team#refresh'

app.put '/teams/:_id/prefs', to: 'team#updatePrefs'

app.post '/teams/joinbyinvitecode', to: 'team#joinByInviteCode'

app.get '/teams/readbyinvitecode', to: 'team#readByInviteCode', middlewares: []

app.resource 'team', only: ['create', 'read', 'readOne', 'update']
# ----------- team --------------

# ----------- room --------------
app.post '/rooms/:_id/join', to: 'room#join'

app.post '/rooms/:_id/leave', to: 'room#leave'

app.post '/rooms/:_id/invite', to: 'room#invite'

app.post '/rooms/:_id/batchInvite', to: 'room#batchInvite'

app.post '/rooms/:_id/archive', to: 'room#archive'

app.post '/rooms/:_id/guest', to: 'room#guest'

app.post '/rooms/:_id/removemember', to: 'room#removeMember'

app.put '/rooms/:_id/prefs', to: 'room#updatePrefs'

app.resource 'room', only: ['create', 'readOne', 'update', 'remove']
# ----------- room --------------

# ----------- story --------------

app.post '/stories/:_id/leave', to: 'story#leave'

app.get '/stories/search', to: 'story#search'

app.post '/stories/search', to: 'story#search'

app.resource 'story', only: ['create', 'readOne', 'read', 'update', 'remove']

# ----------- story --------------

# ----------- group --------------

app.resource 'group', only: ['create', 'read', 'update', 'remove']

# ----------- group --------------

# ----------- usage --------------

app.post '/usages/call', to: 'usage#call'

app.resource 'usage', only: ['read']

# ----------- usage --------------

# ----------- mark --------------

app.resource 'mark', only: ['read', 'remove']

# ----------- mark --------------

# ----------- recommend --------------
app.get '/recommends/friends', to: 'recommend#friends'
# ----------- recommend --------------

# ----------- activity --------------

app.resource 'activity', only: ['read', 'remove']

# ----------- activity --------------

# ----------- integration --------------

# For app load data only
app.get '/integrations/batchread', to: 'integration#batchRead'

app.get '/integrations/checkrss', to: 'integration#checkRSS'

app.post '/integrations/:_id/error', to: 'integration#error'

app.resource 'integration', only: ['create', 'read', 'readOne', 'update', 'remove']
# ----------- integration --------------

# ----------- tag --------------
app.resource 'tag', only: ['create', 'read', 'update', 'remove']
# ----------- tag --------------

# ----------- notification --------------

app.resource 'notification', only: ['create', 'read', 'update']

# ----------- notification --------------

# ----------- discover --------------
app.get '/discover/urlmeta', to: 'discover#urlMeta'

app.get '/strikertoken', to: 'discover#strikerToken'

app.get '/discover', to: 'discover', middlewares: []
# ----------- discover --------------

# ----------- state --------------
app.get '/state', to: 'user#state'
# ----------- state --------------

# ----------- devicetoken --------------
app.resource 'devicetoken', only: ['create']
# ----------- devicetoken --------------

# ----------- service --------------
app.post '/services/webhook/:hashId', to: 'service#webhook', middlewares: []

app.post '/services/api/:category/:apiName', to: 'service#api'

app.get '/services/api/:category/:apiName', to: 'service#api'

app.get '/services/settings', to: 'service#settings'

app.get '/services/toapp', to: 'service#toApp'

app.get '/services/webhook/:hashId', to: 'service#webhook', middlewares: []

app.post '/services/mailgun', to: 'service#mailgun', middlewares: []

app.post '/services/message', to: 'service#createMessage', middlewares: []
# ----------- service --------------

if config.debug then app.get '/mails/:type', to: 'mail#render', middlewares: []

# Switch versions
app.get '/versions/:version', (req, res) ->
  {version} = req.params
  {p} = req.query
  if p is 'geek' then expires = null else expires = new Date(Date.now() + 2592000000)
  res.cookie 'version', version, {domain: config.webHost, expires: expires}
  homeUrl = config.schema + '://' + config.webHost
  res.redirect 302, homeUrl

# -------------- cms --------------
app.middlewares = [auth()] unless config.test

app.get '/cms/users/me', to: 'user#me'

app.resource 'cms/notice', only: ['create', 'read', 'readOne', 'update', 'remove']

# -------------- cms --------------

# -------------- guest --------------
app.middlewares = [authGuest()] unless config.test

app.get '/guest/users/me', to: 'user#me'

app.post '/guest/users/signout', to: 'guest/user#signout'

app.post '/guest/users', to: 'guest/user#create', middlewares: []

app.post '/guest/users/subscribe', to: 'user#subscribe'

app.post '/guest/users/unsubscribe', to: 'user#unsubscribe'

app.get '/guest/state', to: 'guest/user#state'

app.resource 'guest/user', only: ['update']

app.get '/guest/rooms/:guestToken', to: 'guest/room#readOne', middlewares: []

app.post '/guest/rooms/:guestToken/join', to: 'guest/room#join'

app.post '/guest/rooms/:_id/leave', to: 'guest/room#leave'

app.post '/guest/messages/clear', to: 'message#clear'

app.get '/guest/messages', to: 'guest/message#read'

app.resource 'guest/message', ctrl: 'message', only: ['create', 'update', 'remove']

app.get '/guest/strikertoken', to: 'discover#strikerToken'

# -------------- guest --------------

# -------------- admin --------------

app.middlewares = [auth()] unless config.test

app.get '/admin/user', to: 'user#me'

app.get '/admin/teams', to: 'team#read'

app.get '/admin/teams/:_id/members', to: 'team#members'

app.resource '/admin/teams/:_teamId/usage', ctrl: 'usage', only: ['read', 'update']

# -------------- admin --------------

app.get '/_chk', to: 'check#ping', middlewares: []

# 404
app.use (req, res, callback) ->
  res.err = new Err 'NOT_FOUND'
  res.response()

# 500
app.use (err, req, res, callback) ->
  res.err = err
  res.response()
