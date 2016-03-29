express = require 'express'
Err = require 'err1st'

app = express()

callResults =
  '16031610490641240001030600108079':
    statusCode: '000000'
    CallResult:
      state: '1'
      callTime: '8'
  '1603161049064124000103060010807a':
    statusCode: '000000'
    CallResult:
      state: '1'
      callTime: '17'

app.post '/Accounts/:appId/SubAccounts', (req, res) ->
  res.send
    SubAccount:
      voipAccount: 'abc'
      voipPwd: '123'
      subToken: 'afasd'
      subAccountSid: 'fasfasdf'

app.get '/Accounts/:appId/CallResult', (req, res) ->
  req.query.should.have.properties 'sig', 'callsid'
  unless callResults[req.query.callsid]
    throw new Err "Invalid callsid #{req.query.callsid}"
  res.send callResults[req.query.callsid]

app.use (req, res, next) -> res.send ok: 1

module.exports = app
