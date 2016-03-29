messages = db.messages.find({hasTag: null}, {tags: 1})

num = 0

messages.forEach (message) ->
  num += 1
  print "Scan num", num unless num % 10000
  hasTag = if message.tags?.length then true else false
  db.messages.update({_id: message._id}, {$set: {hasTag: hasTag}})

print "Finish num", num
