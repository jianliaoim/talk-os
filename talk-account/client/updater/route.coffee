
Immutable = require 'immutable'

exports.signin = (store) ->
  store.set 'router', Immutable.fromJS
    name: 'signin'
    data: {}
    query: {}

exports.signup = (store) ->
  store.set 'router', Immutable.fromJS
    name: 'signup'
    data: {}
    query: {}

exports.forgotPassword = (store) ->
  store.set 'router', Immutable.fromJS
    name: 'forgot-password'
    data: {}
    query: {}

exports.emailSent = (store) ->
  store.set 'router', Immutable.fromJS
    name: 'email-sent'
    data: {}
    query: {}

exports.succeedResetting = (store) ->
  store.set 'router', Immutable.fromJS
    name: 'succeed-resetting'
    data: {}
    query: {}

exports.succeedBinding = (store) ->
  store.set 'router', Immutable.fromJS
    name: 'succeed-binding'
    data: {}
    query: {}

exports.go = (store, info) ->
  store.set 'router', info
