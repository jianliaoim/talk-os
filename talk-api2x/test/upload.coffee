request = require 'request'
fs = require 'fs'

url = 'http://striker.project.ci/upload'

formData =
  attachments: [
    fs.createReadStream __dirname + '/files/thumbnail.jpg'
    fs.createReadStream __dirname + '/files/page.html'
  ]

request
  method: 'POST'
  url: url
  formData: formData
  json: true
, (err, res, body) ->
  console.log body
