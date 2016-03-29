express = require 'express'

module.exports = app = express()

app.post '/messages', (req, res) -> res.send content: 'ok', authorName: '小艾'
