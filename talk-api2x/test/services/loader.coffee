should = require 'should'
serviceLoader = require 'talk-services'

describe 'Service#Load', ->

  it 'should load all services and append robots to each service', (done) ->

    $incoming = serviceLoader.load 'incoming'

    $incoming.then (incoming) ->
      incoming.robot.isRobot.should.eql true
      incoming.robot.name.should.eql 'Incoming Webhook'
      incoming.robot.service.should.eql 'incoming'

    .nodeify done

  it 'should load all the settings of services', (done) ->

    serviceLoader.settings().then (settings) ->
      settings.length.should.above 0
      settings.forEach (setting) ->
        setting.name.should.not.eql 'talkai'  # Do not show hidden services
        setting.constructor.name.should.eql 'Object'
        setting.should.have.properties 'name', 'title', 'manual'
        setting

    .nodeify done
