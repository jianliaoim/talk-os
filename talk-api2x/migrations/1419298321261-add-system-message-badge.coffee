exports.up = (next) ->
  mongo ->
    messages = db.messages.find()
    num = 0
    messages.forEach (message) ->
      return if message.isManual?
      num += 1
      if message.category is 'system'
        message.isManual = false
        message.displayMode = 'system'
        message.isPushable = false
        message.isMailable = false
        message.isEditable = false
        message.isSearchable = false
      else
        message.isManual = true
        message.displayMode = 'normal'
        message.isPushable = true
        message.isMailable = true

      if message.file
        message.isSearchable = true
        message.displayMode = 'normal'

      delete message.category

      db.messages.save(message)

      print("#{num} messages saved") unless num % 1000
  next()

exports.down = (next) ->
  next()
