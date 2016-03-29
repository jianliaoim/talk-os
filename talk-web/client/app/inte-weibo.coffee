React = require 'react'
Immutable = require 'immutable'
classnames = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

lang    = require '../locales/lang'
TALK    = require '../config'
socket  = require '../network/socket'

inteActions = require '../actions/inte'

handlers = require '../handlers'
mixinCreateTopic = require '../mixin/create-topic'
mixinInteHandler = require '../mixin/inte-handler'
mixinInteEvents  = require '../mixin/inte-events'

isEqual = require 'lodash.isequal'

{div, span, p, a} = React.DOM

T = React.PropTypes
l = lang.getText
weiboEvents = ['mention', 'repost', 'comment']

module.exports = React.createClass
  displayName: 'inte-weibo'
  mixins: [
    LinkedStateMixin
    mixinCreateTopic, mixinInteHandler, mixinInteEvents
    PureRenderMixin
  ]

  propTypes:
    _teamId:  T.string.isRequired
    _roomId:  T.string.isRequired
    onPageBack:  T.func.isRequired
    inte:     T.object
    settings: T.object.isRequired # immutable object
    accounts: T.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    weiboInfo = @props.accounts.find (binding) ->
      binding.get('refer') is 'weibo'

    # state got from weibo
    showname: @props.inte?.get('showname') or weiboInfo?.get('showname') or undefined
    token: weiboInfo?.get('accessToken') or undefined

  componentDidMount: ->
    unless @props.inte?
      @loadWeiboAccount()

  componentWillUnmount: ->
    socket.off 'integration:gettoken', @onGetToken

  # methods

  loadWeiboAccount: ->
    socket.on 'integration:gettoken', @onGetToken

  isToSubmit: ->
    return false unless @state._roomId?
    return false unless @state.events.size > 0
    # should also detect token, leave it todo
    return false unless @state.showname
    return true

  hasChanges: ->
    return true if @state._roomId isnt @props.inte.get('_roomId')
    return true if @state.title isnt @props.inte.get('title')
    return true if @state.description isnt @props.inte.get('description')
    return true if @state.iconUrl isnt @props.inte.get('iconUrl')
    return true unless isEqual @state.events, @props.inte.get('events')
    return false

  # events

  onGetToken: (data) ->
    @setState showname: data.showname, token: data.accessToken, title: data.showname
    handlers.accountBind data

  onNotificationChange: (name) ->
    events = @state.events
    if events[name]?
      delete events[name]
    else
      events[name] = 1
    @setState {events}

  onCreate: ->
    unless @isToSubmit() then return
    return false if @state.isSending

    data =
      _teamId: @props._teamId
      _roomId: @state._roomId
      token: @state.token
      category: 'weibo'
      events: @state.events
      title: @state.title
      description: @state.description
      iconUrl: @state.iconUrl
      showname: @state.showname

    @setState isSending: true
    inteActions.inteCreate data,
      (resp) =>
        @setState isSending: false
        @props.onPageBack true
      (error) =>
        @setState isSending: false

  onUpdate: ->
    unless @isToSubmit() then return
    return false unless @hasChanges()
    return false if @state.isSending

    inte = @props.inte

    data = {}
    data._roomId = @state._roomId if @state._roomId isnt inte._roomId
    data.token = @state.token if @state.token isnt inte.token
    data.title = @state.title if @state.title isnt inte.title
    data.description = @state.description if @state.description isnt inte.description
    data.events = @state.events unless isEqual @state.events, inte.events
    data.iconUrl = @state.iconUrl if @state.iconUrl isnt inte.iconUrl

    @setState isSending: true
    inteActions.inteUpdate @props.inte.get('_id'), data,
      (resp) =>
        @setState isSending: false
        @props.onPageBack true
      (error) =>
        @setState isSending: false

  onWeiboBind: (event) ->
    window.open TALK.weiboLogin

  onExistingBind: ->
    weiboInfo = @props.accounts.find (binding) ->
      binding.get('refer') is 'weibo'
    @setState showname: weiboInfo.get('showname'), token: weiboInfo.get('accessToken')

  # renderers

  renderShowname: ->
    weiboInfo = @props.accounts.find (binding) ->
      binding.get('refer') is 'weibo'

    div className: 'table-pair',
      div className: 'attr',
        div null, l('connect-to-weibo')
      if @state.showname?
        div className: 'value showname-table as-line',
          span className: 'showname', @state.showname
          a className: 'is-trigger', onClick: @onWeiboBind, lang.getText('changeBinding')
      else
        div className: 'value showname-table as-line',
          span className: 'text is-minor', lang.getText('noBinding')
          a className: 'is-trigger', onClick: @onWeiboBind, lang.getText('addBinding')

  render: ->
    div className: 'inte-weibo inte-board lm-content',
      @renderInteHeader()
      @renderTopicRow()
      @renderShowname()
      @renderEvents()

      @renderInteTitle()
      @renderInteDesc()
      @renderInteIcon()

      if @props.inte?
        @renderInteModify()
      else
        @renderInteCreate()

      # modals
      @renderTopicCreate()
