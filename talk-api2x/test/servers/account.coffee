express = require 'express'

module.exports = app = express()

app.get '/v1/user/get', (req, res) ->
  accountToken = req.query['accountToken']
  accountToken.should.eql 'OKKKKKKK'

  data =
    _id: '55f7d19c85efe377996a1232'
    unions:
      [
        refer: 'teambition'
        openId: '55f7d19c85efe377996a1231'
        accessToken: 'afasdfasdfas'
        showname: 'Teambition'
        avatarUrl: 'www.project.ci/striker/png1'
      ,
        refer: 'github'
        openId: '55f7d19c85efe377996a1233'
        accessToken: 'helloworld'
        showname: 'github'
        avatarUrl: 'www.project.ci/striker/png2'
      ]

  res.status(200).json data
