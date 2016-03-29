React   = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'
lang          = require '../locales/lang'

notify  = require '../util/notify'
util    = require '../util/util'
detect  = require '../util/detect'

mixinSubscribe = require '../mixin/subscribe'

browser = util.parseUA().browser

module.exports = React.createClass
  displayName: 'title'

  mixins: [mixinSubscribe]

  getInitialState: ->
    @getState()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState @getState()

  getState: ->
    router = recorder.getState().get('router')
    _teamId = router.getIn(['data', '_teamId'])
    router: router
    team: @getTeam(_teamId)

  getTeam: (_teamId) ->
    query.teamBy(recorder.getState(), _teamId) or null

  getUnread: (_teamId) ->
    store = recorder.getState()
    notifications = store.getIn ['notifications', _teamId]
    if notifications
      notifications.reduce (sum, n) ->
        unreadNum = if n.get('isMute') then 0 else n.get('unreadNum')
        sum + unreadNum
      , 0
    else
      0

  renderTitle: ->
    _teamId = @state.router.getIn(['data', '_teamId'])
    _roomId = @state.router.getIn(['data', '_roomId'])
    _toId = @state.router.getIn(['data', '_toId'])
    _storyId = @state.router.getIn(['data', '_storyId'])

    titleBuffer = ''

    team = @state.team
    if team?
      unreadCount = @getUnread(_teamId)
      notify.favicon unreadCount
      if (unreadCount > 0) and (browser in ['safari', 'ie'])
        titleBuffer = "(#{unreadCount})"
      titleBuffer += team.get('name')
      topic = query.topicsByOne(recorder.getState(), _teamId, _roomId) or null
      contact = query.requestContactsByOne(recorder.getState(), _teamId, _toId) or null
      story = query.storiesByOne(recorder.getState(), _teamId, _storyId)
      if _roomId? and topic?
        if topic.get('isGeneral')
        then titleBuffer += " · #{lang.getText('room-general')}"
        else titleBuffer += " · #{topic.get('topic')}"
      else if _toId? and contact?
        prefs = query.contactPrefsBy(recorder.getState(), _teamId, contact.get('_id'))
        name = prefs?.get('alias') or contact.get('name')
        if (detect.isTalkai contact)
        then titleBuffer += " · #{lang.getText('ai-robot')}"
        else titleBuffer += " · #{name}"
      else if _storyId? and story?
        name = story.get('title')
        titleBuffer += " · #{name}"
    else
      notify.favicon 0
      titleBuffer = lang.getText('talk')
    if document? and document.title isnt titleBuffer
      document.title = titleBuffer

  render: ->
    @renderTitle()
    null
