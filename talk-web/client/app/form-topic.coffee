cx = require 'classnames'
React = require 'react'
Immutable = require 'immutable'

lang = require '../locales/lang'

Textarea = React.createFactory require 'react-textarea-autosize'

{ div, form, span, input, fieldset, noscript, textarea } = React.DOM
T = React.PropTypes

protoData =
  text: ''
  title: ''

module.exports = React.createClass
  displayName: 'form-topic'

  propTypes:
    data: T.instanceOf(Immutable.Map)
    onChange: T.func
    onSubmit: T.func
    readOnly: T.bool
    willSubmit: T.bool
    displayMode: T.oneOf([ 'create', 'edit' ]).isRequired

  getDefaultProps: ->
    onChange: (->)
    onSubmit: (->)
    readOnly: false
    willSubmit: false

  getInitialState: ->
    data: @props.data or Immutable.Map protoData

  componentWillReceiveProps: (nextProps) ->
    if not @props.willSubmit and nextProps.willSubmit
      @props.onSubmit @state.data

    if @props.displayMode is 'create'
      if not nextProps.data?
        @setState
          data: Immutable.Map protoData

    if @props.displayMode is 'edit'
      if not @props.readOnly and nextProps.readOnly
        @setState
          data: @props.data or Immutable.Map protoData

  willChange: (key, value) ->
    newState =
      data: @state.data.set key, value

    @setState newState
    @props.onChange newState.data

  handleTextChange: (event) ->
    @willChange 'text', event.target.value

  handelTitleChange: (event) ->
    @willChange 'title', event.target.value

  onFormSubmit: (event) ->
    event.preventDefault()
    @props.onSubmit @state.data

  render: ->
    form className: 'form-table', onSubmit: @onFormSubmit,
      fieldset {},
        div className: 'form-row',
          input
            type: 'text'
            value: @state.data.get('title') or ''
            onChange: @handelTitleChange
            readOnly: @props.readOnly
            autoFocus: not @props.readOnly
            className: 'text-row font-large'
            placeholder: if not @props.readOnly then lang.getText('share-story-title-placeholder')
        div className: 'form-row',
          Textarea
            value: @state.data.get('text') or ''
            onChange: @handleTextChange
            readOnly: @props.readOnly
            className: 'textarea-row font-normal'
            placeholder: if not @props.readOnly then lang.getText('share-story-desc-placeholder')
