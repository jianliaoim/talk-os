express = require 'express'

module.exports = app = express()

app.get '/', (req, res) -> res.send code: 100000, text: "Hello"
