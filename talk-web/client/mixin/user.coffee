React = require 'react'
recorder = require 'actions-recorder'

query = require '../query'

module.exports =

  getUserId: ->
    query.userId recorder.getState()

  isUser: (target) ->
    target is @getUserId()
