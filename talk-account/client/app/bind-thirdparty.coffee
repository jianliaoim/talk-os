
React = require 'react'
Immutable = require 'immutable'

ajax = require '../ajax'
locales = require '../locales'
controllers = require '../controllers'

Space = React.createFactory require 'react-lite-space'
ForcebindThirdparty = React.createFactory require './forcebind-thirdparty'

{div, span, a} = React.DOM

module.exports = React.createClass
  displayName: 'bind-thirdparty'

  propTypes:
    store: React.PropTypes.instanceOf(Immutable.Map).isRequired

  getInitialState: ->
    showForceBind: false
    bindCode: null
    showname: null
    error: null

  componentDidMount: ->
    if @getAction() is 'bind'
      @bindUnion()
    else
      @signIn()

  getLanguage: ->
    @props.store.getIn(['client', 'language'])

  getAction: ->
    @props.store.getIn(['client', 'serverAction'])

  getQuery: ->
    @props.store.getIn(['router', 'query'])

  getRefer: ->
    @props.store.getIn(['router', 'data', 'refer'])

  isLoading: ->
    @props.store.getIn(['client', 'isLoading'])

  signIn: ->
    ajax.unionSiginIn
      refer: @getRefer()
      data: @getQuery().toJS()
      success: (resp) =>
        controllers.signInRedirect()
      error: (err) =>
        error = JSON.parse err.response
        @setState error: error.message

  bindUnion: ->
    ajax.unionBindX
      refer: @getRefer()
      data: @getQuery().toJS()
      success: (resp) =>
        controllers.signInRedirect()
      error: (err) =>
        error = JSON.parse err.response
        if error.code is 230
          @setState
            showForceBind: true, bindCode: error.data.bindCode
            showname: error.data.showname
        else
          @setState error: error.message

  renderForceBind: ->
    ForcebindThirdparty
      bindCode: @state.bindCode, language: @getLanguage()
      showname: @state.showname

  render: ->
    div className: 'bind-thirdparty control-panel',
      if @state.showForceBind
        @renderForceBind()
      else
        div className: 'as-line-centered',
          if @state.error?
            span className: 'hint-error', @state.error
          else
            span className: 'text-guide', locales.get('checking', @getLanguage())
