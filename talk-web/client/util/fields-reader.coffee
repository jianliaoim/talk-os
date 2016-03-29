# fields is plain mutable array
exports.hasField = (fields, field) ->
  theFields = fields.filter (item) -> item.key is field
  theFields.length > 0

exports.getField = (fields, field) ->
  theFields = fields.filter (item) -> item.key is field
  if theFields.length is 0
    throw new Error 'matched fields are empty'
  else
    theFields[0]
