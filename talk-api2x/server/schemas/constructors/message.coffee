mongoose = require 'mongoose'
Err = require 'err1st'
_ = require 'lodash'
{Schema} = require 'mongoose'
util = require '../../util'
lexer = require 'talk-lexer'

module.exports = MessageSchemaConstructor = ->

  _verifyAttachmentColor = (color) -> if color in ['green', 'red', 'yellow'] then color else undefined

  attachmentSetter = (attachments) ->
    throw new Err("INVALID_OBJECT", 'attachment') unless toString.call(attachments) is '[object Array]'
    message = this
    delete @_attachments
    attachments.map (attachment) ->
      if toString.call(attachment) is '[object Object]'
        {category, data, _id} = attachment
        throw new Err("INVALID_OBJECT", 'Attachment without category') unless category and data
        modelName = "#{category}Attachment"
        Model = message.model modelName
        throw new Err("INVALID_OBJECT", "Can not find model #{modelName}") unless Model
        element =
          _id: _id or mongoose.Types.ObjectId()
          category: category
          color: _verifyAttachmentColor attachment.color
          data: new Model(data).toObject virtuals: false, getters: false
      else throw new Err("INVALID_OBJECT", "Invalid attachment")
      element

  attachmentGetter = (attachments) ->
    return [] unless toString.call(attachments) is '[object Array]'
    unless @_attachments
      message = this
      @_attachments = attachments.map (attachment) ->
        element = _.clone attachment
        {category, data} = element
        try
          modelName = "#{category}Attachment"
          Model = message.model modelName
        catch err
        return attachment unless Model
        element.data = new Model(data).toObject virtuals: true, getters: true
        element
    @_attachments

  MessageSchema = new Schema
    creator: type: Schema.Types.ObjectId, ref: 'User'
    team: type: Schema.Types.ObjectId, ref: 'Team'
    room: type: Schema.Types.ObjectId, ref: 'Room'
    story: type: Schema.Types.ObjectId, ref: 'Story'
    to: type: Schema.Types.ObjectId, ref: 'User'
    mentions: [type: Schema.Types.ObjectId, ref: 'User']
    body: type: String
    authorName: String  # Replacement of bot name
    authorAvatarUrl: type: String, get: util.buildCamoUrl
    attachments: type: Array, set: attachmentSetter, get: attachmentGetter
    isSystem: type: Boolean, default: false
    icon: type: String, default: 'normal'  # Icon of system message
    integration: type: Schema.Types.ObjectId, ref: 'Integration'
    displayType: type: String, default: 'text'
    createdAt: type: Date, default: Date.now
    updatedAt: type: Date, default: Date.now
    urls: type: Array
  ,
    read: 'secondaryPreferred'
    toObject:
      virtuals: true
      getters: true
    toJSON:
      virtuals: true
      getters: true

  MessageSchema.virtual '_creatorId'
    .get -> @creator?._id or @creator
    .set (_id) -> @creator = _id

  MessageSchema.virtual '_roomId'
    .get -> @room?._id or @room
    .set (_id) -> @room = _id

  MessageSchema.virtual '_toId'
    .get -> @to?._id or @to
    .set (_id) -> @to = _id

  MessageSchema.virtual '_teamId'
    .get -> @team?._id or @team
    .set (_id) -> @team = _id

  MessageSchema.virtual '_storyId'
    .get -> @story?._id or @story
    .set (_id) -> @story = _id

  MessageSchema.virtual '_integrationId'
    .get -> @integration?._id or @integration
    .set (_id) -> @integration = _id

  MessageSchema.virtual '_targetId'
    .get ->
      return @_roomId if @_roomId
      return @_toId if @_toId
      return @_storyId if @_storyId

  MessageSchema.virtual 'type'
    .get ->
      return 'room' if @_roomId
      return 'dms' if @_toId
      return 'story' if @_storyId

# ================================= Methods =================================
  MessageSchema.methods.getAlert = ->
    if @body
      text = lexer.stringify @body
    else if @attachments?.length
      attachment = @attachments[0]
      return unless attachment?.category
      {category, data} = attachment
      switch category
        when 'file', 'image'
          text = "{{__info-upload-files}} #{data.fileName}"
        when 'message'
          text = data.message
        when 'quote'
          text = util.stripHtml(data.title or data.text)[0...100]
        when 'rtf', 'snippet'
          text = util.stripHtml(data.text)[0...100]
        when 'speech'
          text = "{{__info-new-speech}}"
        when 'video'
          text = "{{__info-new-video}}"
    text or ''

  MessageSchema
