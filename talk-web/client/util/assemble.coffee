msgDsl = require 'talk-msg-dsl'
Immutable = require 'immutable'

lang = require '../locales/lang'

fillMessage = (content) ->
  content.replace /\{\{__([\w-]+)\}\}/g, (raw, key) ->
    text = lang.getText(key)
    if text then text else raw

exports.notification = (data, team) ->
  contact = data.creator
  body = msgDsl.flattern(msgDsl.read(fillMessage(data.body or '')))

  if team?
    body = "[#{team}]\n#{body}"
  if data.attachments.length > 0
    attachment = data.attachments[0]
    switch attachment.category
      when 'snippet'
        type = 'category-snippet'
      when 'rtf'
        type = 'category-post'
      when 'quote'
        type = 'attachments'
      when 'file'
        type = 'category-file'
      else
        type = 'attachments'
    body = "#{body}\n[#{lang.getText(type)}]"

  title: contact?.name or ''
  icon: contact?.avatarUrl or ''
  body: body

exports.localMessage = ({_roomId, _storyId, _teamId, alias, receiver, sender, talkai}) ->
  params = "&_userId=#{ receiver.get('_id') }"
  receiverName = alias or receiver.get('name')
  [text1, text2, text3, text4, text5] = lang.getText('you-may-invite').split('%s')

  boldName = category: 'bold', model: '', view: " #{receiverName} "
  linkText = category: 'link', view: text4, model: "talk://operation?action=invite#{ params }"
  content = [text1, sender.get('name'), text2, boldName, text3, linkText, text5]
  localMessage =
    _roomId: _roomId
    _teamId: _teamId
    _storyId: _storyId
    _creatorId: talkai.get('_id')
    body: msgDsl.write content
    creator: talkai
    isEditable: false
    isLocal: true

exports.localTalkMessage = ({body, talkai, _teamId, _roomId, _storyId}) ->
  localMessage =
    _teamId: _teamId
    _roomId: _roomId
    _storyId: _storyId
    _creatorId: talkai.get '_id'
    body: body
    creator: talkai
    isLocal: true
    isEditable: false

exports.allMembers = ->
  _id: 'all'
  name: lang.getText('all-members')
  pinyins: if lang.getLang() is 'zh' then ['suoyou'] else ['all']
  avatarUrl: 'https://dn-talk.oss.aliyuncs.com/icons/all-members.png'

exports.storyFile = (data) ->
  Immutable.fromJS
    fileKey: data.fileKey or ''
    fileName: data.fileName or ''
    fileSize: data.fileSize or ''
    fileType: data.fileType or ''
    imageWidth: data.imageWidth or ''
    previewUrl: data.previewUrl or ''
    downloadUrl: data.downloadUrl or ''
    imageHeight: data.imageHeight or ''
    fileCategory: data.fileCategory or ''
    thumbnailUrl: data.thumbnailUrl or ''
    title: data.fileName or ''

exports.storyLink = (data, url) ->
  Immutable.fromJS
    text: data.text or ''
    title: data.title or url
    imageUrl: data.imageUrl or ''
    faviconUrl: data.faviconUrl or ''
    url: data.url or url

exports.draftStory = (_teamId, _id, category) ->
  data =
    switch category
      when 'file'
        fileKey: ''
        fileName: ''
        fileSize: ''
        fileType: ''
        previewUrl: ''
        imageWidth: ''
        downloadUrl: ''
        imageHeight: ''
        fileCategory: ''
        thumbnailUrl: ''
      when 'link'
        url: ''
        text: ''
        title: ''
        imageUrl: ''
        faviconUrl: ''
      when 'topic'
        text: ''
        title: ''
      else {}

  Immutable.fromJS
    _teamId: _teamId
    _draftId: _id
    _memberIds: []
    data: data
    text: ''
    title: ''
    members: []
    category: category
