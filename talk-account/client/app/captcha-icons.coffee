
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
detect = require '../util/detect'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'

{div, button, form, img, input, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'captcha-icons'

  propTypes:
    onSelect: React.PropTypes.func.isRequired
    lang: React.PropTypes.string.isRequired
    isDone: React.PropTypes.bool.isRequired

  getInitialState: ->
    info: null
    isForbidden: false
    error: null

  componentDidMount: ->
    @loadSetupInfo()

  loadSetupInfo: ->
    ajax.captchaSetup
      data:
        num: 5
        lang: @props.lang
      success: (resp) =>
        @setState info: resp
      error: (err) =>
        # error = JSON.parse err.response

  onRefresh: ->
    @setState info: null, error: null
    @props.onSelect null
    @loadSetupInfo()

  onCheck: (index) ->
    ajax.captchaValid
      data:
        uid: @state.info.uid
        value: @state.info.values[index]
      error: (err) =>
        if err.status is 429
          @setState isForbidden: true
        @setState error: err.response
      success: (resp) =>
        if resp.valid
          @props.onSelect @state.info.uid
        else
          @setState error: locales.get('invalidedCaptchaTryAgain', @props.lang)
          @loadSetupInfo()

  renderChooser: ->
    guideText = locales.get('pleaseSelectX', @props.lang)
    .replace '%s', @state.info.imageName

    div className: 'captcha-icons is-default',
      div className: 'as-head',
        span className: 'text-guide', guideText
        span className: 'icon icon-refresh', onClick: @onRefresh
      Space height: 10
      div className: 'as-body',
        @state.info.values.map (imageId, index) =>
          imageUrl = ajax.captchaImage @state.info.uid, @props.lang, index
          onCheck = => @onCheck index
          img key: index, className: 'captcha-icon', src: imageUrl, onClick: onCheck
      if @state.error?
        div className: 'as-response',
          Space height: 10
          span className: 'hint-error', @state.error

  renderLoading: ->
    div className: 'captcha-icons is-loading',
      locales.get('loading', @props.lang)

  renderDone: ->
    div className: 'captcha-icons is-successful',
      span className: 'icon icon-circle-check'
      Space width: 5
      span className: 'text-guide', locales.get('captchaSucceed', @props.lang)

  renderForbidden: ->
    div className: 'captcha-icon is-forbidden',
      span className: 'hint-error', locales.get('captchaTooManyTime', @props.lang)

  render: ->
    if @props.isDone
      @renderDone()
    else if @state.isForbidden
      @renderForbidden()
    else if @state.info?
      @renderChooser()
    else
      @renderLoading()
