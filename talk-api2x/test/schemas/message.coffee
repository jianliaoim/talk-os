should = require 'should'
app = require '../app'
limbo = require 'limbo'
async = require 'async'
{prepare, cleanup} = app

{
  MessageModel
} = limbo.use 'talk'

describe 'Schemas#Message', ->

  _newMessage = ->
    new MessageModel
      creator: app.user1._id
      team: app.team1._id
      room: app.room1._id

  before (done) ->
    async.series [
      app.createUsers
      app.createTeams
      app.createRooms
    ], done

  it 'should save basic message', (done) ->
    message = _newMessage()
    message.body = "Hello <$at|1|@someone$>"

    message.save (err, message) ->
      message.should.have.properties 'body', 'isSystem'
      message.isSystem.should.eql false
      message.getAlert().should.eql "Hello @someone"
      done err

  it 'should save file message', (done) ->
    message = _newMessage()

    file =
      category: 'file'
      data:
        fileKey: '2a4a216c6095750ec4840925a14ebad1'
        fileName: 'New File'
        fileType: 'png'

    message.attachments = [file]

    message.save (err, message) ->
      return done err if err
      MessageModel.findOne _id: message._id, (err, message) ->
        message.attachments.length.should.eql 1
        message.attachments[0].should.have.properties 'category', 'data', '_id'
        message.attachments[0].data.should.have.properties 'downloadUrl', 'previewUrl'
        done err

  it 'should save quote message', (done) ->
    message = _newMessage()
    attachment =
      category: 'quote'
      data:
        title: 'Title'
        text: 'Text'
    message.attachments = [attachment]
    message.save (err, message) ->
      return done err if err
      MessageModel.findOne _id: message._id, (err, message) ->
        message.attachments.length.should.eql 1
        message.attachments[0].should.have.properties 'category', 'data', '_id'
        message.attachments[0].data.should.have.properties 'title', 'text'
        done err

  it 'should update the attachments', (done) ->
    message = _newMessage()
    file1 =
      category: 'file'
      data: fileKey: "2a4a216c6095750ec4840925a14ebad1"
    file2 =
      category: 'file'
      data: fileKey: '2a4a216c6095750ec4840925a14ebad2'
    message.attachments = [file1]
    message.save (err, message) ->
      return done err if err
      {attachments} = message
      attachments.push file2
      message.attachments = attachments
      message.save (err, message) ->
        return done err if err
        MessageModel.findOne _id: message._id, (err, message) ->
          return done err if err
          message.attachments.length.should.eql 2
          message.attachments.forEach (attachment) ->
            {category, data} = attachment
            category.should.eql 'file'
            data.should.have.properties 'downloadUrl', 'previewUrl'
          done err

  it 'should save displayType propertype and provied with default value', (done) ->
    message = _newMessage()

    message.save (err, message) ->
      message.should.have.properties 'displayType'
      message.displayType.should.eql 'text'
      done err

  after cleanup
