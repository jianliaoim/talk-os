
React = require 'react'
recorder = require 'actions-recorder'
classnames = require 'classnames'

url = require '../util/url'
lang = require '../locales/lang'
config = require '../config'
util = require '../util/util'

reqwest = require '../util/reqwest'

notifyActions = require '../actions/notify'

{div, span, a, textarea, input, label, button} = React.DOM
PureRenderMixin = require 'react-addons-pure-render-mixin'

module.exports = React.createClass
  displayName: 'about-feedback'
  mixins: [PureRenderMixin]

  # no props

  getInitialState: ->
    text: ''
    email: recorder.getStore().getIn(['user', 'email']) or ''
    isLoading: false

  onChange: (event) ->
    @setState text: event.target.value

  onEmailChange: (event) ->
    @setState email: event.target.value

  onSubmit: ->
    text = @state.text.trim()
    if text.length > 0
      if @state.email
        text += "\n\n回访邮箱: #{@state.email}"
      else
        text += '\n\n没有提供回访邮箱'
      @setState isLoading: false
      user = recorder.getStore().get('user')
      reqwest
        url: config.feedbackUrl
        method: 'post'
        contentType: 'application/json'
        data: JSON.stringify
          authorName: user.get('name')
          title: lang.getText('user-feedback')
          text: util.withMachineInfo(text, recorder.getStore())
        success: (resp) =>
          @setState text: '', isLoading: false
          notifyActions.info lang.getText('feedback-success')
        error: (error) =>
          @setState isLoading: false
          notifyActions.warn "#{lang.getText('api-failed')} #{error.responseText}"

  render: ->
    buttonClass = classnames 'button', 'is-extended', 'is-primary',
      'is-disabled': @state.text.trim().length is 0

    div className: 'about-feedback',
      div className: 'feedback-box lm-content',
        div className: 'form-group',
          div className: 'guide-line', lang.getText('send-us-feedback1')
          if lang.getLang() isnt 'en'
            div className: 'guide-line',
              span className: 'feedback-mail', lang.getText('feedback-mail')
              a href: url.feedbackUrl, target: '_blank',
                ' 简聊发烧友'
              lang.getText('comma')
              a href: url.issueUrl, target: '_blank',
                'Teambition 简聊反馈项目'
              lang.getText('comma')
              lang.getText('or')
              lang.getText('send-us-feedback2')
          textarea
            className: 'as-content form-control'
            rows: 5
            value: @state.text
            onChange: @onChange
        div className: 'form-group',
          div className: 'guide-line', lang.getText('return-visit-email')
          input
            value: @state.email, onChange: @onEmailChange, type: 'email'
            className: 'form-control'
            placeholder: lang.getText('email')
        div className: 'form-group',
          button className: buttonClass, onClick: @onSubmit, lang.getText('send')
