React = require 'react'
ReactDOM = require 'react-dom'
recorder = require 'actions-recorder'

schema = require '../schema'
updater = require '../updater'

require('./main.less')
require '../network/receiver'

dispatcher = require '../dispatcher'

Util    = require '../util/util'

handlers = require './handlers'

routes = require './routes'
Container = React.createFactory require '../guest-app/container'

if Util.parseUA(window.navigator.userAgent).os is 'windows'
  document.body.className = 'is-windows'

# initialize app

recorder.setup
  initial: schema.database
  inProduction: false
  updater: updater

render = (core) ->
  store = core.get('store')
  ReactDOM.render Container({store, core}), document.querySelector('.app')

recorder.request render
recorder.subscribe render

# initialize networks
handlers.initialize()

if module.hot
  module.hot.accept ['../guest-app/container'], ->
    Container = React.createFactory require '../guest-app/container'
    recorder.request render
