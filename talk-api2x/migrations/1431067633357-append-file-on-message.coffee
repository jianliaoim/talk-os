exports.up = (next) ->
  mongo ->
    messages = db.messages.find({file: $ne: null})
    messages.forEach (message) ->
      file = db.files.findOne _id: message.file
      message.file = if file then file else null
      db.messages.save(message)
  next()

exports.down = (next) ->
  mongo ->
    messages = db.messages.find({'file._id': $ne: null})
    messages.forEach (message) ->
      message.file = message.file._id
      db.messages.save message
  next()
