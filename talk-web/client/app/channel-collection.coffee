Immutable = require 'immutable'
React     = require 'react'
recorder = require 'actions-recorder'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
routerHandlers = require '../handlers/router'
deviceActions = require '../actions/device'
settingsActions = require '../actions/settings'

mixinSubscribe = require '../mixin/subscribe'

lang            = require '../locales/lang'

orders = require '../util/orders'
detect = require '../util/detect'

FileQueueCollection = React.createFactory require './file-queue-collection'

MsgFile    = React.createFactory require './msg-file'
MsgPost    = React.createFactory require './msg-post'
MsgLink    = React.createFactory require './msg-link'
MsgSnippet = React.createFactory require './msg-snippet'

Icon = React.createFactory require '../module/icon'
LightModal = React.createFactory require '../module/light-modal'

{ a, h3, h4, div, span } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'channel-collection'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    _teamId: T.string.isRequired
    _channelId: T.string.isRequired
    _channelType: T.string.isRequired

  getInitialState: ->
    # returns object
    fileMessages: @getFileMessages()
    linkMessages: @getLinkMessages()
    postMessages: @getPostMessages()
    snippetMessages: @getSnippetMessages()
    channelMessages: @getChannelMessages()
    showFileQueue:   false
    cursorAttachment: null

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        channelMessages: @getChannelMessages()
        fileMessages: @getFileMessages()
        postMessages: @getPostMessages()
        linkMessages: @getLinkMessages()
        snippetMessages: @getSnippetMessages()

  getChannelMessages: ->
    channelMessages = query.messagesBy(recorder.getState(), @props._teamId, @props._channelId) or Immutable.List()
    channelMessages.filterNot (message) -> detect.isMessageFake(message)

  getFileMessages: ->
    query.fileMessagesBy(recorder.getState(), @props._teamId, @props._channelId) or Immutable.List()

  getPostMessages: ->
    query.postMessagesBy(recorder.getState(), @props._teamId, @props._channelId) or Immutable.List()

  getLinkMessages: ->
    query.linkMessagesBy(recorder.getState(), @props._teamId, @props._channelId) or Immutable.List()

  getSnippetMessages: ->
    query.snippetMessagesBy(recorder.getState(), @props._teamId, @props._channelId) or Immutable.List()

  filterMessages: ->
    existedIds = @state.fileMessages.map (message) -> message.get('_id')
    newFiles = @state.channelMessages.filter (message) -> not existedIds.contains(message.get('_id'))
    @state.fileMessages.concat(newFiles).sort(orders.imMsgByLargerId)

  filterFileAttachments: ->
    @filterMessages().map (message) ->
      message.get('attachments')
      .filter (attachment) ->
        attachment.get('category') is 'file'
    .flatten(true)

  filterPostMessages: ->
    existedIds = @state.postMessages.map (message) -> message.get('_id')
    inChannel = @state.channelMessages.filter (message) ->
      hasAttachments = message.get('attachments').size isnt 0
      return unless hasAttachments
      return message.get('attachments').first().get('category') is 'rtf'
    newPosts = inChannel.filter (message) -> not existedIds.contains(message.get('_id'))
    @state.postMessages.concat(newPosts).sort(orders.imMsgByLargerId)

  filterLinkMessages: ->
    existedIds = @state.linkMessages.map (message) -> message.get('_id')
    inChannel = @state.channelMessages.filter (message) ->
      hasAttachments = message.get('attachments').size isnt 0
      return unless hasAttachments
      return message.get('attachments').first().get('category') is 'quote'
    newLinks = inChannel.filter (message) -> not existedIds.contains(message.get('_id'))
    @state.linkMessages.concat(newLinks).sort(orders.imMsgByLargerId)

  filterSnippetMessages: ->
    existedIds = @state.snippetMessages.map (message) -> message.get('_id')
    inChannel = @state.channelMessages.filter (message) ->
      hasAttachments = message.get('attachments').size isnt 0
      return unless hasAttachments
      return message.get('attachments').first().get('category') is 'snippet'
    newSnippet = inChannel.filter (message) -> not existedIds.contains(message.get('_id'))
    @state.snippetMessages.concat(newSnippet).sort(orders.imMsgByLargerId)

  # events
  routeToCollectionPage: (type) ->
    searchQuery =
      type: type
    switch @props._channelType
      when 'room'
        searchQuery._roomId = @props._channelId
      when 'chat'
        searchQuery._toId = @props._channelId
      when 'story'
        searchQuery._storyId = @props._channelId
    routerHandlers.collection @props._teamId, searchQuery

  onFileManage: ->
    @routeToCollectionPage('file')

  onPostManage: ->
    @routeToCollectionPage('rtf')

  onLinkManage: ->
    @routeToCollectionPage('url')

  onSnippetManage: ->
    @routeToCollectionPage('snippet')

  onFileClick: (attachment) ->
    @setState showFileQueue: true, cursorAttachment: attachment
    deviceActions.viewAttachment attachment.get('_id')

  onFileQueueHide: ->
    @setState showFileQueue: false
    deviceActions.viewAttachment null

  onCloseDrawer: ->
    settingsActions.closeDrawer()

  # renderers

  renderFiles: (fileMessages) ->
    return null if fileMessages.size is 0

    messages = fileMessages.take(10).map (attachment) =>
      MsgFile key: attachment.get('_id'), attachment: attachment, onClick: @onFileClick

    div className: 'group',
      h4 className: 'title', lang.getText('category-file')
      messages
      if fileMessages.size > 10
        span className: 'more', onClick: @onFileManage,
          lang.getText('show-more')

  renderPosts: (postMessages) ->
    return null if postMessages.size is 0

    messages = postMessages.take(10).map (message) ->
      MsgPost key: message.get('_id'), message: message

    div className: 'group',
      h4 className: 'title', lang.getText('category-post')
      messages
      if postMessages.size > 10
        span className: 'more', onClick: @onPostManage,
          lang.getText('show-more')

  renderLinks: (linkMessages) ->
    return null if linkMessages.size is 0

    messages = linkMessages.take(10).map (message) ->
      MsgLink key: message.get('_id'), message: message

    div className: 'group',
      h4 className: 'title', lang.getText('category-link')
      messages
      if linkMessages.size > 10
        span className: 'more', onClick: @onLinkManage,
          lang.getText('show-more')

  renderSnippets: (snippetMessages) ->
    return null if snippetMessages.size is 0

    messages = snippetMessages.take(10).map (message) ->
      MsgSnippet key: message.get('_id'), message: message

    div className: 'group',
      h4 className: 'title', lang.getText('category-snippet')
      messages
      if snippetMessages.size > 10
        span className: 'more', onClick: @onSnippetManage,
          lang.getText('show-more')

  renderFileQueue: ->
    LightModal
      name: 'file-queue'
      show: @state.showFileQueue
      onCloseClick: @onFileQueueHide
      FileQueueCollection
        onClose: @onFileQueueHide
        messages: @filterMessages()
        attachment: @state.cursorAttachment

  renderHeader: ->
    div className: 'header',
      h3 className: 'title', lang.getText 'automatic-collection'
      div className: 'action',
        Icon
          name: 'remove', size: 18
          onClick: @onCloseDrawer
          className: 'muted'

  renderBody: ->
    fileMessages    = @filterFileAttachments()
    postMessages    = @filterPostMessages()
    linkMessages    = @filterLinkMessages()
    snippetMessages = @filterSnippetMessages()

    div className: 'body thin-scroll',
      @renderFiles(fileMessages)
      @renderPosts(postMessages)
      @renderLinks(linkMessages)
      @renderSnippets(snippetMessages)
      if (fileMessages.size + postMessages.size + linkMessages.size + snippetMessages.size) is 0
        div className: 'muted', lang.getText('about-collection')

  render: ->
    div className: 'channel-collection',
      @renderHeader()
      @renderBody()
      @renderFileQueue()
