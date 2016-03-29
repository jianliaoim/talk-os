exports.up = (next) ->
  mongo ->
    robot = db.users.findOne name: 'talkai', isRobot: true
    teams = db.teams.find()
    teams.forEach (team) ->
      db.members.update
        user: robot._id
        team: team._id
      ,
        user: robot._id
        team: team._id
        isQuit: false
        role: 'member'
        createdAt: ISODate()
        updatedAt: ISODate()
      , upsert: true

      room = db.rooms.findOne team: team._id, isGeneral: true
      if room?._id
        db.members.update
          user: robot._id
          room: room._id
        ,
          user: robot._id
          room: room._id
          isQuit: false
          role: 'member'
          createdAt: ISODate()
          updatedAt: ISODate()
        , upsert: true
  next()

exports.down = (next) ->
  mongo ->
    robot = db.users.findOne name: 'talkai', isRobot: true
    db.members.remove user: robot._id
  next()
