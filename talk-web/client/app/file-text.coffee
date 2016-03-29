React = require 'react'
hljs = require 'highlight.js/lib/highlight'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

reqwest = require '../util/reqwest'

lang = require '../locales/lang'

LoadingIndicator = React.createFactory require('react-lite-misc').LoadingIndicator

div    = React.createFactory 'div'
pre = React.createFactory 'pre'
code = React.createFactory 'code'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-text'
  mixins: [PureRenderMixin]

  propTypes:
    file: T.instanceOf(Immutable.Map)

  getInitialState: ->
    loading: true
    text: null

  componentDidMount: ->
    @loadTextContent()

  loadTextContent: ->
    # file server rejects X-Socket-Id, so bypass api.get
    # and X-Requested-With is added by reqwest by default
    reqwest
      url: @props.file.get('downloadUrl')
      method: 'get'
      type: 'text'
      success: (resp) =>
        # text, html, css and JSON supported
        @setState text: resp.responseText, loading: false
      error: (resp) =>
        failedText = "#{lang.getText('text-download-failed')}: #{@props.file.get('fileName')}"
        @setState text: failedText, loading: false

  renderCode: ->
    result = hljs.highlightAuto (@state.text or '')
    pre {},
      code
        className: result.language
        dangerouslySetInnerHTML:
          __html: result.value

  render: ->

    div className: 'file-text',
      if @state.loading
        LoadingIndicator()
      else
        div className: 'text-container',
          @renderCode()
