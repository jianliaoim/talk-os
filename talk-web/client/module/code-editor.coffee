cx = require 'classnames'
React = require 'react'

if typeof window isnt 'undefined'
  codemirror = require 'codemirror'
  require 'codemirror/addon/display/placeholder'

div = React.createFactory 'div'
textarea = React.createFactory 'textarea'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'lite-code-editor'

  propTypes:
    readOnly: T.bool
    onChange: T.func.isRequired
    codeType: T.string
    name: T.string
    placeholder: T.string
    text: T.string

  getDefaultProps: ->
    codeType: 'null'
    placeholder: 'Code goes here...'
    readOnly: false
    text: ''

  componentDidMount: ->
    @initEditor()

  componentWillReceiveProps: (nextProps) ->
    if @editor.getOption('mode') isnt nextProps.codeType
      @editor.setOption 'mode', nextProps.codeType

  initEditor: ->
    @option =
      indentUnit: 2
      indentWithTabs: false
      lineNumbers: true
      lineWrapping: false
      mode: @props.codeType
      placeholder: @props.placeholder
      readOnly: @props.readOnly
      smartIndent: true
      tabMode: 'spaces'
      tabSize: 2
      theme: 'default'
      extraKeys:
        'Tab': (cm) ->
          cm.replaceSelection '  ', 'end'
    editor = @refs.editor
    @editor = codemirror.fromTextArea editor, @option
    @editor.on 'change', @onEditorChange

  onEditorChange: ->
    value = @editor.getValue()
    @props.onChange value

  renderEditor: ->
    textarea
      className: 'editor'
      defaultValue: @props.text
      readOnly: @props.readOnly
      ref: 'editor'
      onChange: @props.onChange

  render: ->
    className = cx
      'lite-code-editor': true
      "is-for-#{ @props.name }": @props.name?

    div className: className,
      @renderEditor()
