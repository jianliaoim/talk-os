exports.up = (next) ->
  mongo ->
    db.members.update({}, {$set: {hasVisited: true}}, {multi: true})
  next()

exports.down = (next) ->
  next()
