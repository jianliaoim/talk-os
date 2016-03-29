
require 'volubile-ui/ui/index.less'
require 'volubile-ui/ui/fonts/roboto.less'

React = require 'react'
ReactDOM = require 'react-dom'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

ajax = require './ajax/index'
schema = require './schema'
updater = require './updater'
analytics = require './util/analytics'
controllers = require './controllers'

Page = React.createFactory require './app/page'

serverStore = Immutable.fromJS window._initialStore

routerName = serverStore.getIn(['router', 'name'])
# special rule to set default account to be '+86'
if routerName is 'bind-mobile'
  serverStore = serverStore.setIn ['client', 'account'], '+86'
# recover referer form localStorage in email and thirdparty callbacks
generatedRoutes = ['reset-password', 'bind-thirdparty', 'verify-email']
if routerName in generatedRoutes
  if not serverStore.getIn(['client', 'referer'])?
    referer = controllers.takeRefererFromStorage()
    serverStore = serverStore.setIn ['client', 'referer'], referer

recorder.setup
  initial: schema.store.merge(serverStore)
  updater: updater

render = (core) ->
  ReactDOM.render Page({core}),
    document.querySelector('#app')

recorder.request render
recorder.subscribe render

switch routerName
  when '/', 'signin', 'access' then analytics.loginReady()
  when 'signup' then analytics.registerReady()
