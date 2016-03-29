React = require 'react'
PdfViewer = require 'pdfviewer'
TALK = require '../config'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

div = React.createFactory 'div'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-pdf'
  mixins: [PureRenderMixin]

  getInitialState: ->
    error: false

  propTypes:
    file: T.instanceOf(Immutable.Map)

  componentDidMount: ->
    @loadPdf()

  loadPdf: ->
    container = @refs.root
    url = @props.file.get('previewUrl') or @props.file.get('downloadUrl')

    new PdfViewer
      pdfUrl: url
      staticHost: TALK.pdfStaticHost
      onerror: =>
        if @isMounted()
          @setState
            error: true
    .embed(container)


  render: ->

    div className: 'file-pdf',
      div ref: 'root', className: 'pdf-container'
      if @state.error
        div className: 'error', lang.getText('file-preview-error')
