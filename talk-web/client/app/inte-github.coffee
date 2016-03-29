React = require 'react'
Immutable = require 'immutable'
classnames = require 'classnames'

PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'


TALK = require '../config'

inteActions = require '../actions/inte'

lang = require '../locales/lang'

handlers = require '../handlers'
mixinInteEvents = require '../mixin/inte-events'
mixinCreateTopic = require '../mixin/create-topic'
mixinInteHandler = require '../mixin/inte-handler'

socket = require '../network/socket'

LiteLoadingMore = React.createFactory require('react-lite-misc').LoadingMore

a = React.createFactory 'a'
div = React.createFactory 'div'
span = React.createFactory 'span'
input = React.createFactory 'input'
button = React.createFactory 'button'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'inte-github'
  mixins: [
    LinkedStateMixin
    mixinCreateTopic, mixinInteHandler, mixinInteEvents
    PureRenderMixin
  ]

  propTypes:
    _teamId:  T.string.isRequired
    _roomId:  T.string.isRequired
    onPageBack:  T.func.isRequired
    onInteEdit:  T.func.isRequired
    inte:     T.object
    settings: T.object.isRequired # immutable object
    accounts: T.instanceOf(Immutable.List).isRequired

  getInitialState: ->
    githubInfo = @props.accounts.find (binding) ->
      binding.get('refer') is 'github'

    configKind = 'manual' # or "webhook"
    if @props.inte? and not @props.inte.get('token')?
      configKind = 'webhook'

    configKind: configKind
    webhookUrl: @props.inte?.get('webhookUrl') or ''
    repo: @props.inte?.getIn(['repos', 0]) or ''
    token: githubInfo?.get('accessToken') or undefined
    showname: @props.inte?.get('showname') or githubInfo?.get('showname') or null

  componentDidMount: ->
    socket.on 'integration:gettoken', @onTokenLoad

  componentWillUnmoumt: ->
    socket.off 'integration:gettoken', @onTokenLoad

  isToSubmit: ->
    return false unless @state._roomId?
    if @state.configKind is 'manual'
      return false unless @state.events.size > 0
      return false unless @state.repo?.match(/^[\w-\.]+\/[\w-\.]+$/)
    return true

  hasChanges: ->
    return true if @state._roomId isnt @props.inte.get('_roomId')
    return true if @state.title isnt @props.inte.get('title')
    return true if @state.description isnt @props.inte.get('description')
    return true if @state.iconUrl isnt @props.inte.get('iconUrl')
    if @state.configKind is 'manual'
      return true unless Immutable.is @state.events, @props.inte.get('events')
      return true unless Immutable.is @state.repos, @props.inte.get('repos')
    return false

  onTokenLoad: (data) ->
    @setState showname: data.showname, token: data.accessToken
    handlers.accountBind data
    return

  onCreateWebhook: ->
    # only _roomId need to be checked here, it's special case
    return false unless @state._roomId?

    return false if @state.isSending

    data =
      _teamId: @props._teamId
      _roomId: @state._roomId
      category: @props.settings.get('name')

    @setState isSending: true
    inteActions.inteCreate data,
      (resp) =>
        @setState webhookUrl: resp.webhookUrl, isSending: false
        @props.onInteEdit Immutable.fromJS(resp)
      (error) =>
        @setState isSending: false

  onCreate: ->
    return false unless @isToSubmit()
    return if @state.isSending

    if @state.configKind is 'manual'
      data =
        # returns an object
        _teamId: @props._teamId
        _roomId: @state._roomId
        category: 'github'
        token: @state.token
        events: @state.events
        repos: [@state.repo]
        title: @state.title
        description: @state.description
        iconUrl: @state.iconUrl
        showname: @state.showname

      @setState isSending: true
      inteActions.inteCreate data,
        (resp) =>
          @setState isSending: false
          @onPageBack true
        (error) =>
          @setState isSending: false
    else
      @onCreateWebhook()

  onUpdate: ->
    return false unless @hasChanges()
    return false unless @isToSubmit()
    return false if @state.isSending

    inte = @props.inte

    data = {}
    # token and showname are not supposed to change
    data._roomId = @state._roomId if @state._roomId isnt inte._roomId
    data.events = @state.events unless Immutable.is @state.events, inte.events
    data.repos = @state.repos unless Immutable.is @state.repos, inte.repos
    data.title = @state.title unless @state.title is inte.title
    data.description = @state.description unless @state.description is inte.description
    data.iconUrl = @state.iconUrl unless @state.iconUrl is inte.iconUrl

    @setState isSending: true
    inteActions.inteUpdate @props.inte.get('_id'), data,
      (resp) =>
        @setState isSending: false
        @onPageBack true
      (error) =>
        @setState isSending: false

  onRepoChange: (event) ->
    @setState repo: event.target.value

  onGithubBind: ->
    window.open TALK.githubLogin

  onExistingBind: ->
    githubInfo = @props.accounts.find (binding) ->
      binding.get('refer') is 'github'
    @setState showname: githubInfo.get('showname'), token: githubInfo.get('accessToken')

  onKindUseManual: ->
    @setState configKind: 'manual'

  onKindUseWebhook: ->
    @setState configKind: 'webhook'

  # renderers

  renderKindSwitcher: ->
    manualClass = classnames 'config-kind',
      'is-selected': @state.configKind is 'manual'
    webhookClass = classnames 'config-kind',
      'is-selected': @state.configKind is 'webhook'

    div className: 'table-pair',
      span className: 'attr', lang.getText('config-github-by-webhook')
      div className: 'value',
        div className: 'github-tip', lang.getText('about-github-webhook')
        a className: manualClass, onClick: @onKindUseManual, lang.getText('config-github-manually')
        a className: webhookClass, onClick: @onKindUseWebhook, lang.getText('config-github-webhook')

  renderShowname: ->
    githubInfo = @props.accounts.find (binding) ->
      binding.get('refer') is 'github'

    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('connect-to-github')
      if @state.showname?
        div className: 'value showname-table as-line',
          span className: 'showname', @state.showname
          a className: 'is-trigger', onClick: @onGithubBind, lang.getText('changeBinding')
      else
        div className: 'value showname-table as-line',
          span className: 'text is-minor', lang.getText('noBinding')
          a className: 'is-trigger', onClick: @onGithubBind, lang.getText('addBinding')

  renderRepoSelector: ->
    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('choose-repo')
      div className: 'value',
        input
          className: 'form-control', placeholder: lang.getText('fill-repo-name'), type: 'text'
          onChange: @onRepoChange, value: @state.repo

  render: ->

    div className: 'inte-github inte-board lm-content',

      @renderInteHeader()
      @renderTopicRow()

      if not @props.inte?
        @renderKindSwitcher()

      switch @state.configKind
        when 'manual'
          div className: 'switcher-block',
            @renderShowname()
            @renderRepoSelector()
            @renderEvents()
        when 'webhook'
          if @props.inte?
            div className: 'switcher-block',
              @renderWebhookUrl @state.webhookUrl

      if @props.inte? or (@state.configKind is 'manual')
        div null,
          @renderInteTitle()
          @renderInteDesc()
          @renderInteIcon()

      if @props.inte?
        @renderInteModify()
      else
        @renderInteCreate()

      # modals
      @renderTopicCreate()
