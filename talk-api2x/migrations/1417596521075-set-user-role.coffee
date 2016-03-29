exports.up = (next) ->
  mongo ->
    users = db.users.find()
    users.forEach (user) ->
      return if user.globalRole
      user.globalRole = 'user'
      db.users.save(user)
  next()

exports.down = (next) ->
  next()
