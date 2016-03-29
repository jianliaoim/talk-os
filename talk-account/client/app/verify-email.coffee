
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
ForcebindEmail = React.createFactory require './forcebind-email'

{div, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'verify-email-mobile'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showForceBind: false
    showname: null
    error: null

  componentDidMount: ->
    @bindEmail()

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  getToken: ->
    decodeURIComponent @props.store.getIn(['router', 'query', 'verifyToken'])

  getAction: ->
    @props.store.getIn ['router', 'query', 'action']

  isLoading: ->
    @props.store.getIn(['client', 'isLoading'])

  bindEmail: ->
    if @getAction() is 'bind'
      ajax.emailBind
        data:
          verifyToken: @getToken()
        success: (resp) =>
          controllers.routeSucceedBinding()
          setTimeout =>
            window.close()
          , 3000
        error: (err) =>
          error = JSON.parse err.response
          if error.code is 230
            @setState
              showForceBind: true, bindCode: error.data.bindCode
              showname: error.data.showname
          else
            @setState error: error.message
    else
      ajax.emailChange
        data:
          verifyToken: @getToken()
        success: (resp) =>
          controllers.routeSucceedBinding()
          setTimeout =>
            window.close()
          , 3000
        error: (err) =>
          error = JSON.parse err.response
          if error.code is 230
            @setState
              showForceBind: true, bindCode: error.data.bindCode
              showname: error.data.showname
          else
            @setState error: error.message

  renderForceBind: ->
    ForcebindEmail
      bindCode: @state.bindCode, language: @getLanguage()
      showname: @state.showname

  render: ->
    div className: 'verify-email control-panel',
      if @state.showForceBind
        @renderForceBind()
      else
        div className: 'as-line-centered',
          if @state.error?
            span className: 'hint-error', @state.error
          else
            span className: 'hint-text', locales.get('checking', @getLanguage())
