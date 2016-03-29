exports.up = (next) ->
  mongo ->
    robots = db.users.find isRobot: true
    robots.forEach (robot) ->
      return if robot.name is 'talkai'
      db.members.remove user: robot._id
  next()

exports.down = (next) ->
  next()
