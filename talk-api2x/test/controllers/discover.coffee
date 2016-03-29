async = require 'async'
should = require 'should'

{cleanup, request} = app = require '../app'

describe 'controllers -> discover#strikerToken', ->

  before app.prepare

  it 'should get striker token', (done) ->
    options =
      method: 'get'
      url: '/strikertoken'
    request options, (err, res, strikertoken) ->
      strikertoken.should.have.property 'token'
      strikertoken.token.should.not.be.empty()
      strikertoken.token.should.have.startWith 'Bearer'
      done err

  it 'should get meta infomation of url', (done) ->
    options =
      method: 'GET'
      url: '/discover/urlmeta'
      qs: url: 'www.baidu.com'
    request options, (err, res, meta) ->
      meta.should.have.properties 'title'
      done err

  after cleanup
