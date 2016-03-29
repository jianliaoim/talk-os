exports.up = (next) ->
  mongo ->
    pages = db.pages.find()
    pages.forEach (page) ->
      page.template or= 'email'
      db.pages.save(page)
  next()

exports.down = (next) ->
  next()
