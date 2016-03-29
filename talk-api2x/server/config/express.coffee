path = require 'path'

express = require 'express'
morgan = require 'morgan'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
favicon = require 'serve-favicon'
jade = require 'jade'
multer  = require 'multer'
i18n = require 'i18n'
logger = require 'graceful-logger'
app = require '../server'

config = require 'config'

app.engine 'jade', jade.__express
app.set 'json spaces', 0
app.set 'query parser', 'extended'

app.set 'views', path.join(__dirname, '../../views')
app.set 'view cache', true
app.set 'view engine', 'jade'

morgan.token 'client', (req, res) ->
  {clientType} = req.get()
  clientType or= 'web'
  "talk_#{clientType}"

morgan.token 'user',  (req, res) -> req.get '_sessionUserId'

morgan.token 'params', (req, res) ->
  data = {}
  data[key] = val for key, val of req.query
  data[key] = val for key, val of req.body
  Object.keys(data).toString()

unless config.test
  app.use morgan("[:date] :client :user :method :url :params :user-agent :status :res[content-length] :response-time ms")

app.use favicon(path.join(__dirname, '../../public/favicon.ico'))
app.use bodyParser.json(limit: '10mb')
app.use bodyParser.urlencoded(extended: true, limit: '10mb')
app.use multer(rename: (fieldname, filename) -> filename)
app.use cookieParser()
# Init i18n middleware and set locale from cookie, query and header
app.use i18n.init
app.use (req, res, next) ->
  locale = req.query?.lang or req.body?.lang or req.headers?['x-language'] or req.cookies?.lang
  req.setLocale locale if locale in ['en', 'zh']
  next()

unless config.test
  app.use (req, res, next) ->
    logger.info "Req #{req.method} #{req.url} #{Object.keys(req.query)} #{Object.keys(req.body)}"
    next()

app.use "/#{config.apiVersion}/public", express.static(path.join(__dirname, '../../public'))

# Add common headers to all requests
app.all '*', (req, res, next) ->
  res.header "Access-Control-Allow-Headers", "Authorization, Content-Type, X-Socket-Id, X-Client-Type, X-Client-Id, X-Language"
  next()
