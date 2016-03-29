dispatcher = require '../dispatcher'

['warn', 'error', 'info', 'success'].forEach (method) ->
  exports[method] = (text) ->
    dispatcher.handleViewAction
      type: 'notify-banner/create'
      data:
        type: method
        text: text

exports.clear = ->
  dispatcher.handleViewAction
    type: 'notify-banner/clear'
