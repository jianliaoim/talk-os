request = require 'request'
fs = require 'fs'

mailgun = require '../controllers/mailgun.json'
mailgun.recipient = 'youjian.r42d675a070@mail.jianliao.com'
mailgun.file = fs.createReadStream __dirname + '/../files/thumbnail.jpg'

options =
  method: 'POST'
  url: 'http://talk.bi/v2/services/mailgun'
  formData: mailgun

request options, (err, res, body) -> console.log err, body
