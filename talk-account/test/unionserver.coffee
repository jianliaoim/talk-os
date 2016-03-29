express = require 'express'
should = require 'should'
bodyParser = require 'body-parser'
app = express()

app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true

# Fake teambition application
tbApp = express()

tbApp.post '/account/oauth2/access_token', (req, res) ->
  req.body.should.have.properties 'client_id', 'client_secret', 'code', 'grant_type'
  res.json access_token: 'abc'

tbApp.get '/api/users/me', (req, res) ->
  req.headers.should.have.properties 'authorization'
  req.headers.authorization.should.eql 'OAuth2 abc'
  res.json
    _id: '55ed1e3aaa6373be1e9fd60a'
    name: 'teambition 用户'
    email: 'jianliao@teambition.com'
    avatarUrl: 'https://mailimg.teambition.com/logos/2.png'

app.use '/tb', tbApp

# Fake github application

gbApp = express()

gbApp.post '/account/oauth/access_token', (req, res) ->
  req.body.should.have.properties 'client_id', 'client_secret', 'code'
  res.json access_token: 'abc'

gbApp.get '/api/user', (req, res) ->
  req.headers.should.have.properties 'authorization'
  req.headers.authorization.should.eql 'token abc'
  req.headers['user-agent'].should.eql 'jianliao'

  res.json
    id: '1111111'
    login: '简聊'
    name: 'github 用户'
    avatar_url: 'https://github.com/fluidicon.png'

app.use '/gb', gbApp

# Fake weibo application
wbApp = express()

wbApp.post '/account/oauth2/access_token', (req, res) ->
  req.query.should.have.properties 'client_id', 'client_secret', 'grant_type', 'redirect_uri', 'code'
  res.json
    access_token: 'abc'
    uid: '1234567890'

wbApp.get '/api/2/users/show.json', (req, res) ->
  req.query.should.have.properties 'access_token', 'uid'
  res.json
    id: '1234567890'
    name: '微博用户'
    screen_name: "简聊"
    profile_image_url: 'http://tp1.sinaimg.cn/3374131524/180/5733730527/0'

app.use '/wb', wbApp

# Fake trello application
tlApp = express()

splitString = (items) ->
  # Converting string segment joined by "=" to dictionary pair.
  # 'OAuth oauth_consumer_key="6c1b69dcbfca9842889bf2f5c55a25e5",oauth_nonce="37cee0fe54c84ff187de3f77a0c039eb"'
  # will be {oauth_consumer_key: '6c1b69dcbfca9842889bf2f5c55a25e5', oauth_nonce: '37cee0fe54c84ff187de3f77a0c039eb'}
  itemDict = {}
  splitItems = items.split(/[, ]/)
  for item in splitItems
    splitedItem = item.split("=")
    if splitedItem[1]
      itemDict[splitedItem[0]] = splitedItem[1].replace(/^"|"$/g, "")
  itemDict

tlApp.post '/OAuthGetRequestToken', (req, res) ->
  req_oauth = splitString req.headers.authorization
  req_oauth.should.have.properties 'oauth_callback', 'oauth_consumer_key'
  req_oauth.oauth_callback.should.eql 'http%3A%2F%2Faccount.talk.bi%2Funion%2Fcallback%2Ftrello'
  req_oauth.oauth_consumer_key.should.eql '6c1b69dcbfca9842889bf2f5c55a25e5'
  res.json 'oauth_token=trello_request_token_step_1&oauth_token_secret=trello_request_token_step_1&oauth_callback_confirmed=true'

tlApp.post '/OAuthGetAccessToken', (req, res) ->
  req_oauth = splitString req.headers.authorization
  req_oauth.oauth_token.should.eql 'trello_authorize_token_step_2'
  req_oauth.oauth_verifier.should.eql 'trello_authorize_verifier_step_2'
  res.json 'oauth_token=trello_access_token_step_3&oauth_token_secret=trello_access_token_secret_step_3'

tlApp.get '/tokens/:token/member', (req, res) ->
  req.query.should.have.property 'key'
  req.params.token.should.eql 'trello_access_token_step_3'
  req.query.key.should.eql '6c1b69dcbfca9842889bf2f5c55a25e5'
  res.json
    id: '1234567'
    username: 'trello 用户'
    fullname: '简聊'
    gravatarHash: '12344'

app.use '/tl', tlApp

app.listen 7632
