
assign = require 'object-assign'

# methods copied from talk-web

exports.gaEvent = (category, action, label, value) ->
  window.ga? 'send',
    hitType: 'event',
    eventCategory: category,
    eventAction: action,
    eventLabel: label
    eventValue: value

exports.gaTiming = (category, variable, value) ->
  window.ga? 'send',
    hitType: 'timing'
    timingCategory: category
    timingVar: variable
    timingValue: value

exports.mixpanel = (event, properties) ->
  window.mixpanel?.track event, properties

exports.event = (category, action, label, value) ->
  properties =
    category: category
    label: label
    value: value
  exports.mixpanel action, properties
  exports.gaEvent category, action, label, value

# events

if typeof window isnt 'undefined'
  window.mixpanel?.time_event 'login ready'
  window.mixpanel?.time_event 'register ready'

exports.loginReady = -> exports.event 'login', 'login ready'
exports.registerReady = -> exports.event 'login', 'register ready'
exports.loginError = -> exports.event 'login', 'login error'
exports.registerError = -> exports.event 'login', 'register error'
