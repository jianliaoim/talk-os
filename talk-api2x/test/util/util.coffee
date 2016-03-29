should = require 'should'
util = require '../../server/util'

describe 'Util#fetchUrlMetas', ->

  @timeout 5000

  it 'should fetch the meta infomation of talk.ai', (done) ->
    util.fetchUrlMetas 'https://talk.ai/site'

    .then (meta) ->
      meta.should.have.properties 'title', 'text'

    .nodeify done

  it 'should fetch the infomation on the gbk site', (done) ->
    util.fetchUrlMetas 'http://err.tmall.com/error1.html'

    .then (meta) ->
      meta.should.have.properties 'title'

    .nodeify done

