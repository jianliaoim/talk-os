exports.up = (next) ->
  mongo ->
    preferences = db.preferences.find()
    preferences.forEach (preference) ->
      return unless preference.user
      db.preferences.remove _id: preference._id
      preference._id = preference.user
      delete preference.user
      db.preferences.save preference
  next()

exports.down = (next) ->
  next()
