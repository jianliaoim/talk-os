devicetokens = db.devicetokens.find().sort({updatedAt: -1})

dtMap = {}
tokenMap = {}

removeCount = 0

devicetokens.forEach (dt) ->
  key = "#{dt.user}#{dt.type}#{dt.clientId}"
  if dtMap[key] or tokenMap[dt.token] or not dt.clientId
    print "Remove", JSON.stringify(dt)
    removeCount += 1
    db.devicetokens.remove({_id: dt._id})
  else
    # Log key index
    dtMap[key] = dt._id
    tokenMap[dt.token] = dt._id

print "Removed count", removeCount
