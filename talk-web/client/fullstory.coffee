eventBus = require './event-bus'

eventBus.once 'fullstory', (user) ->
  if window.FS?
    window.FS.identify user._id,
      displayName: user.name
