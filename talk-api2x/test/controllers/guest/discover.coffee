async = require 'async'
should = require 'should'

{cleanup, request} = app = require '../../app'

describe 'controllers -> guest/discover#strikerToken', ->

  before app.prepare

  it 'should get striker token', (done) ->
    options =
      method: 'get'
      url: 'guest/strikertoken'
    request options, (err, res, strikertoken) ->
      strikertoken.should.have.property 'token'
      strikertoken.token.should.not.be.empty()
      strikertoken.token.should.have.startWith 'Bearer'
      done err

  after cleanup
