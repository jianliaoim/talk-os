should = require 'should'
config = require 'config'
requestUtil = require '../../server/util/request'

describe 'Util#sendSMS', ->

  return unless config.testPhoneNumber

  it "should send sms message to #{config.testPhoneNumber}", (done) ->
    options =
      phoneNumber: config.testPhoneNumber
      ip: req.headers['x-real-ip'] or req.ip
      _userId: 'new'
      refer: 'jianliao_test'
      msg: "测试消息，妈妈叫你去吃饭"
    requestUtil.sendSMS options

    .then (body) ->
      console.log body
      done()

    .catch done
