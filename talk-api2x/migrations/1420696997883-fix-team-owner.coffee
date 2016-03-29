exports.up = (next) ->
  mongo ->
    # Fix team creators
    teams = db.teams.find creator: null
    teams.forEach (team) ->
      owner = db.members.findOne team: team._id, role: 'owner'
      owner = db.members.findOne team: team._id, role: 'admin' unless owner
      owner = db.members.findOne team: team._id unless owner
      return unless owner.user
      team.creator = owner.user
      db.teams.save team
      owner.role = 'owner'
      db.members.save owner
    # Fix room creators
    rooms = db.rooms.find creator: null
    rooms.forEach (room) ->
      return unless room.team
      team = db.teams.findOne _id: room.team
      room.creator = team.creator
      db.rooms.save room
  next()

exports.down = (next) ->
  next()
