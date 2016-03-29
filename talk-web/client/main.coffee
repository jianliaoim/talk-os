require './main.less'

parse = require 'url-parse'
React = require 'react'
ReactDOM = require 'react-dom'
pathUtil = require 'router-view/lib/path'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

TALK = require './talk'
routes = require './routes'
schema = require './schema'
updater = require './updater'
eventBus = require './event-bus'

dev = require './util/dev'
time = require './util/time'
analytics = require './util/analytics'

teamActions = require './actions/team'
userActions = require './actions/user'
notifyBannerActions = require './actions/notify-banner'

initHanlders = require './handlers/initialize'
unreadHanlders = require './handlers/unread'
networkHandlers = require './handlers/network'

lang = require './locales/lang'

socket = require './network/socket'
storage = require './network/storage'

util = require './util/util'

require './network/receiver'
require './util/highlightjs'
require './util/overload'
require './tour-guide'

Container = React.createFactory require './app/container'

window.initNwPlugin? lang.getLang()
if __GA__
  require('q').longStackSupport = true

unless navigator.onLine
  document.body.textContent = 'Please Connect To the Internet.'

else
  # send Google Analytics events
  talkUrl = parse location.href, true
  # if talkUrl.query.status is 'signup-success' then 'user signed up successfully'

  # store default router info, will be useful in first loading
  oldAddress = "#{location.pathname}#{location.search}"
  defaultRouteInfo = pathUtil.getCurrentInfo routes, oldAddress

  # if new user, force redirect to setting-rookie page
  if defaultRouteInfo.get('query').get('wasNew') is 'true'
    defaultRouteInfo = defaultRouteInfo.set 'name', 'setting-rookie'

  # initialize store
  defaultInfo =
    # defaultRouteInfo will be updated in data rely
    initial: Immutable.fromJS(window._initialStore)
    inProduction: true
    updater: updater

  if util.parseUA(navigator.userAgent).os is 'windows'
    document.body.className = 'is-windows'

  lastSession = storage.get()

  if lastSession.get('settings')?
    defaultInfo.initial = defaultInfo.initial.set 'settings', lastSession.get('settings')
  if lastSession.get('drafts')?
    defaultInfo.initial = defaultInfo.initial.set 'drafts', lastSession.get('drafts')

  recorder.setup defaultInfo

  initHanlders.start defaultRouteInfo, ->
    # don't render page too early, Safari 8 has a bug of popstate during loading
    # https://github.com/visionmedia/page.js/issues/213
    # if Addressbar is mounted too early, page got a flicking in routing
    render = (core) ->
      ReactDOM.render Container({core}), document.querySelector('.app')
    recorder.request render
    recorder.subscribe render

    unreadHanlders.simulateRead()
    analytics.readLoadingPerfs()

  analytics.detectTrackingInfoFromAccount()
  analytics.registerSuperProperties()
  analytics.trackAppLoaded()

  if module.hot
    module.hot.accept ['./updater', './schema'], ->
      schema = require './schema'
      updater = require './updater'
      recorder.hotSetup
        initial: defaultInfo.initial
        updater: updater
    module.hot.accept ['./app/container'], ->
      Container = React.createFactory require './app/container'
      render recorder.getCore()
