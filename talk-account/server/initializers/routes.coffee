Err = require 'err1st'
jade = require 'jade'
path = require 'path'
config = require 'config'
logger = require 'graceful-logger'
express = require 'express'

app = require '../server'
locales = require '../../client/locales'
renderer = require '../../client/entry/renderer'

app.engine 'jade', jade.__express
app.set 'views', path.join(__dirname, '../views')
app.set 'view cache', true
app.set 'view engine', 'jade'

################################## 页面响应callback ##########################
apiCallback = (req, res) ->
  {err, result} = res
  if err
    err = new Err(err) unless err instanceof Err
    logger.info req.method, req.url, err.stack if err.code is 100

    res.status(err.status or 400).json
      code: err.code
      message: err.locale(req.getLocale()).message
      data: err.data or {}
  else
    res.status(200).json(result)

################################## 页面路由 ##################################
app.get '/', to: 'signin#redirect'
app.get '/signin', to: 'signin#render'
app.get '/access', to: 'signin#render'
app.get '/signup', renderer

app.get '/forgot-password', renderer
app.get '/reset-password', renderer # callback page from email
app.get '/succeed-resetting', renderer

app.get '/email-sent', renderer

app.get '/bind-mobile', renderer
app.get '/verify-mobile', renderer

app.get '/succeed-binding', renderer

app.get '/bind-email', renderer
app.get '/verify-email', renderer # callback page from email

app.get '/email/preview', to: 'email#preview' if config.debug

# static file server for developing
app.use '/build', express.static(path.join(__dirname, '../../build/'))
################################## API 路由 ##################################

app.routeCallback = apiCallback

app.routePrefix = '/v1'

app.post '/email/sendverifycode', to: 'email#sendVerifyCode'

app.post '/email/resetpassword', to: 'email#resetPassword'

app.post '/email/signinbyverifycode', to: 'email#signinByVerifyCode'

app.post '/email/bind', to: 'email#bind'

app.post '/email/change', to: 'email#change'

app.post '/email/forcebind', to: 'email#forcebind'

app.post '/email/unbind', to: 'email#unbind'

app.post '/mobile/signinbyverifycode', to: 'mobile#signinByVerifyCode'

app.post '/mobile/resetpassword', to: 'mobile#resetPassword'

app.post '/mobile/sendverifycode', to: 'mobile#sendVerifyCode'

app.post '/mobile/signin', to: 'mobile#signin'

app.post '/mobile/signup', to: 'mobile#signup'

app.post '/mobile/bind', to: 'mobile#bind'

app.post '/mobile/change', to: 'mobile#change'

app.post '/mobile/forcebind', to: 'mobile#forcebind'

app.post '/mobile/unbind', to: 'mobile#unbind'

app.post '/email/signup', to: 'email#signup'

app.post '/email/signin', to: 'email#signin'

app.get '/user/get', to: 'user#get'

app.get '/user/accounts', to: 'user#accounts'

app.get '/_chk', to: 'check#ping'

app.use '/v1', (req, res, callback) ->
  res.err = new Err 'NOT_FOUND'
  apiCallback.call this, req, res

app.use '/v1', (err, req, res, callback) ->
  res.err = err
  apiCallback.call this, req, res

################################## not found ##################################
app.use (req, res, callback) ->
  res.err = new Err('NOT_FOUND')
  renderer req, res

################################## error ##################################
app.use (err, req, res, callback) ->
  res.err = err
  renderer req, res
