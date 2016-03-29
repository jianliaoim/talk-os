fs = require 'fs'
path = require 'path'
config = require 'config'

_request = require 'request'
mailgun = require '../controllers/mailgun.json'
mailgun.recipient = 'self4.r68c12a25@talk.ai'
# mailgun.attachment = fs.createReadStream __dirname + "/../files/jzzslb.doc"
mailgun.attach1 = fs.createReadStream __dirname + '/../main.coffee'
url = 'http://talk.bi/' + path.join(config.apiVersion, 'services/mailgun')

_request.post
  url: url
  formData: mailgun
, (err, res, body) ->
  console.log err, body
