React = require 'react'
debounce = require 'debounce'
PureRenderMixin = require 'react-addons-pure-render-mixin'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

inteActions = require '../actions/inte'

lang = require '../locales/lang'

mixinCreateTopic = require '../mixin/create-topic'
mixinInteHandler = require '../mixin/inte-handler'

LiteLoadingIndicator = React.createFactory require('react-lite-misc').LoadingIndicator

p = React.createFactory 'p'
div = React.createFactory 'div'
input = React.createFactory 'input'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'inte-rss'
  mixins: [
    mixinCreateTopic, mixinInteHandler
    LinkedStateMixin
    PureRenderMixin
  ]

  propTypes:
    _teamId:  T.string.isRequired
    _roomId:  T.string.isRequired
    onPageBack:  T.func.isRequired
    inte:     T.object
    settings: T.object.isRequired # immutable object

  getInitialState: ->
    step:         null
    url:          @props.inte?.get('url') or undefined

  componentDidMount: ->
    @debouncedDetectUrl = debounce @detectUrl, 1000

  # methods

  detectUrl: ->
    url = @state.url.trim()
    if url.length is 0 then return

    @setState step: 'loading'
    inteActions.checkRss url,
      (resp) =>
        @setState step: 'ok', title: resp.title, description: resp.description
      (error) =>
        error =  JSON.parse error.response
        if error.code is 410
          @setState step: 'error'
        else
          @setState step: 'invalid'

  hasChanges: ->
    return true if @state._roomId isnt @props.inte.get('_roomId')
    return true if @state.title isnt @props.inte.get('title')
    return true if @state.iconUrl isnt @props.inte.get('iconUrl')
    return true if @state.description isnt @props.inte.get('description')
    return false

  isToSubmit: ->
    unless @state._roomId then return false
    unless @state.url then return false
    return true

  # events

  onUrlChange: (event) ->
    @setState url: event.target.value, step: null
    @debouncedDetectUrl()

  onCreate: ->
    return false unless @state._roomId? and @state.step is 'ok'
    return false if @state.isSending

    data =
      _teamId: @props._teamId
      _roomId: @state._roomId
      category: 'rss'
      url: @state.url
      showname: @state.title
      title: @state.title
      description: @state.description
      iconUrl: @state.iconUrl

    @setState isSending: true
    inteActions.inteCreate data,
      (resp) =>
        @setState isSending: false
        @props.onPageBack true
      (error) =>
        @setState isSending: false

  onUpdate: ->
    return false unless @hasChanges()
    return false if @state.isSending

    inte = @props.inte

    data = {}
    data._roomId = @state._roomId if @state._roomId isnt inte._roomId
    data.url = @state.url if @state.url isnt inte.url
    data.title = @state.title if @state.title isnt inte.title
    data.description = @state.description if @state.description isnt inte.description
    data.iconUrl = @state.iconUrl if @state.iconUrl isnt inte.iconUrl

    @setState isSending: true
    inteActions.inteUpdate @props.inte.get('_id'), data,
      (resp) =>
        @setState isSending: false
        @onPageBack true
      (error) =>
        @setState isSending: false

  # renderers

  renderHint: ->
    switch @state.step
      when 'loading' then LiteLoadingIndicator()
      when 'error' then p className: 'info error-info text-danger',
        "× #{lang.getText('no-rss-found')}"
      when 'invalid' then p className: 'info invalid-info text-danger',
        "× #{lang.getText('rss-url-invalid')}"

  renderRssEntry: ->
    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('rss-url-to-integrate')
      div className: 'value',
        input
          className: 'form-control', value: @state.url, type: 'text'
          onChange: @onUrlChange, placeholder: lang.getText('paste-rss-url')
        @renderHint()

  render: ->

    div className: 'inte-rss inte-board lm-content',
      @renderInteHeader()
      @renderTopicRow()
      @renderRssEntry()

      @renderInteTitle()
      @renderInteDesc()
      @renderInteIcon()
      if @props.inte?
        @renderInteModify()
      else
        @renderInteCreate()

      # modals
      @renderTopicCreate()
