
Err = require 'err1st'
config = require 'config'
logger = require 'graceful-logger'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

routes = require '../routes'
schema = require '../schema'
locales = require '../locales'
template = require './template'

routerUtil = require 'router-view/lib/path'

module.exports = (req, res) ->
  router = routerUtil.getCurrentInfo routes, req.originalUrl
  next_url = req.cookies?.next_url

  {accounts, user} = req.get()

  store = schema.store
  # 设置用户信息
  .set 'user', Immutable.fromJS user
  # 设置路由
  .set 'router', router
  # configured siteUrl for redirecting
  .setIn ['client', 'siteUrl'], config.siteUrl
  .setIn ['config', 'siteUrl'], config.siteUrl
  .setIn ['config', 'accountUrl'], config.accountUrl
  .setIn ['config', 'cookieDomain'], config.cookieDomain
  .setIn ['config', 'weiboLogin'], config.weiboLogin
  .setIn ['config', 'firimLogin'], config.firimLogin
  .setIn ['config', 'githubLogin'], config.githubLogin
  .setIn ['config', 'trelloLogin'], config.trelloLogin
  .setIn ['config', 'teambitionLogin'], config.teambitionLogin
  # language detected from cookie and headers
  .setIn ['client', 'language'], req.getLocale()
  # /bind-thirdparty need an `method` for further behaviors
  .setIn ['client', 'serverAction'], (req.cookies?.method or null)
  # remember refer, client router will probably rewrite `query`
  .setIn ['client', 'referer'], router.getIn(['query', 'next_url']) or next_url
  # page of /accounts renders a list of accounts
  .setIn ['page', 'accounts'], Immutable.fromJS(accounts)
  .setIn ['client', 'captchaService'], config.captchaService

  if res.err?
    if res.err.code is 404
      res.status res.err.status
      store = store.set 'serverError', Immutable.fromJS
        status: 404
        message: locales.get('pageNotFound', req.getLocale())
    else
      err = new Err(res.err) unless res.err instanceof Err
      # copied logics to write status code
      logger.warn err.stack if config.debug or err.code is 100
      res.status err.status
      store = store.set 'serverError', Immutable.fromJS
        status: err.status
        message: err.message

  recorder.setup initial: store
  res.end template.render(recorder.getCore())
