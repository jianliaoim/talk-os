should = require 'should'

detect = require '../../../client/util/detect'

describe 'client/util/detect', ->

  it 'should recognize QQ format email', (done) ->

    emails = [
      '12345@qq.com', 'abcde@qq.cn'
      '12345@foxmail.com', 'abcde@foxmail.com'
      '12345@QQ.com', 'abcde@QQ.com'
      '12345@qqe.com', 'abcde@qqe.com'
      'qq@12345.com', 'qq@abcde.com'
    ]

    expectResult = [
      true, true
      false, false
      true, true
      false, false
      false, false
    ]

    result = emails.map (email) ->
      detect.isQQEmail email

    result.should.eql expectResult
    done()
