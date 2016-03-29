path = require 'path'

express = require 'express'
morgan = require 'morgan'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
config = require 'config'
logger = require 'graceful-logger'

i18n = require 'i18n'

app = require '../server'

app.use morgan("[:date] :method :url :status :res[content-length] :response-time ms")

app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)
app.use cookieParser()

# Log latest request
app.use (req, res, next) ->
  logger.info "Req #{req.method} #{req.url} #{Object.keys(req.query)} #{Object.keys(req.body)}"
  next()

# Init i18n middleware and set locale from cookie, query and header
app.use i18n.init
app.use (req, res, next) ->
  locale = req.query?.lang or req.body?.lang or req.headers?['x-language'] or req.cookies?.lang
  req.setLocale locale if locale in ['en', 'zh']
  next()
