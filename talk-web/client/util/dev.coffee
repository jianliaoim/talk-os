TALK = require '../config'

['log', 'info', 'warn', 'error', 'trace', 'group', 'groupEnd'].forEach (option) ->
  exports[option] = (args...) ->
    if TALK.env is 'dev'
      console[option] args...
