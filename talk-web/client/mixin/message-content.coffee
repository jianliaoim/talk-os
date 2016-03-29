parse = require 'url-parse'
React = require 'react'
msgDsl = require 'talk-msg-dsl'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

roomActions = require '../actions/room'
storyActions = require '../actions/story'
messageActions = require '../actions/message'

query = require '../query'
config = require '../config'
handlers = require '../handlers'
eventBus = require '../event-bus'

lang = require '../locales/lang'

url = require '../util/url'
emojiUtil = require '../util/emoji'
analytics = require '../util/analytics'

Markdown = React.createFactory require '../module/markdown'

{ div, span } = React.DOM

module.exports =

  hasContent: ->
    # can be array or string
    content = @props.message.get('body')
    content? and content.length > 0

  getDslTable: ->
    _teamId = @props.message.get('_teamId')
    contacts = query.contactsBy(recorder.getState(), _teamId) # an immutable store
    if contacts?
      contacts
      .map (contact) ->
        prefs = query.contactPrefsBy(recorder.getState(), _teamId, contact.get('_id'))
        name = prefs?.get('alias') or contact.get('name')

        caretory: 'at'
        model: contact.get('_id')
        view: "@#{name}"
      .toJS()
    else
      []

  ###
   * 这一段代码的用途是点击本地消息后, 如果有 'talk:' 的链接
   * 则去探测是否是有效的邀请链接
   * 并发出邀请 request
   *
   * [部分逻辑具有问题, 等待改良]
  ###
  onInviteMember: (talkUrl) ->
    userId = talkUrl.query._userId

    if not userId?
      messageActions.deleteLocal @props.message
      return

    _teamId = @props.message.get '_teamId'
    if @props.message.get('_roomId')?
      _roomId = @props.message.get('_roomId')
      data =
        _userId: userId
      roomActions.roomInvite _roomId, data, =>
        messageActions.deleteLocal @props.message
    else if @props.message.get('_storyId')?
      _storyId = @props.message.get('_storyId')
      data =
        addMembers: [userId]
      storyActions.update _storyId, data, =>
        messageActions.deleteLocal @props.message

  onContentClick: (event) ->
    if event.target.tagName is 'A'
      event.stopPropagation()
      event.preventDefault()
      href = event.target.href or ''
      talkUrl = parse href, true
      mentionId = event.target.dataset.mentionId
      roomId = event.target.dataset.roomId
      _teamId = @props.message.get('_teamId')

      if (talkUrl.protocol is 'talk:') and (talkUrl.hostname is 'operation')
        if talkUrl.query.action is 'invite'
          @onInviteMember talkUrl
      else if mentionId?
        return if config.isGuest # guest has no permission, skip
        handlers.routerChat _teamId, mentionId
      else if roomId?
        return if config.isGuest # guest has no permission, skip
        handlers.routerRoom _teamId, roomId
      else if url.isInRoutes(location.origin, href)
        routePath = href.substr(location.origin.length)
        handlers.routerGoPath routePath
      else
        window.open href
        analytics.viewLink()

  makeTag: (dsl) ->
    switch dsl.category
      when 'at'
        if dsl.model is 'all'
          "<strong>@#{lang.getText('all-members')}</strong>"
        else
          "<a data-mention-id=\"#{dsl.model}\">#{dsl.view}</a>"
      when 'room'
        "<a data-room-id=\"#{dsl.model}\">#{dsl.view}</a>"
      else
        dsl

  makeMarkdownTag: (dsl) ->
    switch dsl.category
      when 'at'
        if dsl.model is 'all'
          "**@#{lang.getText('all-members')}**"
        else
          "[#{dsl.view}](){data-mention-id=#{dsl.model}}"
      when 'room'
        "[#{dsl.view}](){data-room-id=#{dsl.model}}"
      else dsl

  renderContent: ->
    body = @props.message.get('body') or ''
    displayType = @props.message.get('displayType')

    if body.length > 1000
      div className: 'content', onClick: @onContentClick, body
    else
      content = msgDsl.update msgDsl.read(body), @getDslTable()
      if displayType is 'markdown'
        content = msgDsl.flattern content, null, @makeMarkdownTag
      else
        content = msgDsl.writeHtml content, @makeTag

      content = content
      .replace /\{\{__([\w-]+)\}\}/g, (raw, key) ->
        text = lang.getText(key)
        if text then text else raw

      if displayType is 'markdown'
        div className: 'content', onClick: @onContentClick,
          Markdown value: content
      else
        content = emojiUtil.replace content
        div className: 'content', onClick: @onContentClick, dangerouslySetInnerHTML: __html: content
