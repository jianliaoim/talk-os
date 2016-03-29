exports.up = (next) ->
  mongo ->
    teams = db.teams.find()
    teams.forEach (team) ->
      member = db.members.findOne _id: team.creator
      return unless member
      team.creator = member.user
      db.teams.save team
    rooms = db.rooms.find()
    rooms.forEach (room) ->
      member = db.members.findOne _id: room.creator
      return unless member
      room.creator = member.user
      db.rooms.save room
  next()

exports.down = (next) ->
  next()
