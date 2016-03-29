cx = require 'classnames'
React = require 'react'
FileAPI = require 'fileapi'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

colors    = require '../util/colors'
uploadUtil  = require '../util/upload'

teamActions = require '../actions/team'

lang = require '../locales/lang'
handlers = require '../handlers'

notifyActions = require '../actions/notify'

LiteCopyarea = React.createFactory require('react-lite-misc').Copyarea
LiteColorChooser = React.createFactory require('react-lite-misc').ColorChooser

{ a, i, div, span, input, label, button, noscript } = React.DOM

T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-configs'
  mixins: [PureRenderMixin]

  propTypes:
    data:           T.instanceOf(Immutable.Map)
    hasPermission:  T.bool.isRequired
    onClose:        T.func.isRequired

  getInitialState: ->
    name: @props.data.get 'name'
    description: @props.data.get 'description'
    shortName: @props.data.get('shortName') or ''
    isErrorShortName: false
    logoUrl: @props.data.get('logoUrl') or undefined

  onNameChange: (event) ->
    if @props.hasPermission
      name = event.target.value
      @setState name: name

  onDescriptionChange: (event) ->
    if @props.hasPermission
      @setState description: event.target.value

  onShortNameChange: (event) ->
    if @props.hasPermission
      if event.target.value.length > 0
        isErrorShortName = not (/^[a-z_-]+$/i).test event.target.value

      @setState
        shortName: event.target.value
        isErrorShortName: isErrorShortName

  needSave: ->
    isValidName = @state.name isnt @props.data.get 'name'
    isValidShortName = @state.shortName isnt @props.data.get 'shortName'
    isValidDescription = @state.description isnt @props.data.get 'description'
    isValidlogoUrl = @state.logoUrl isnt @props.data.get('description')

    isValidName or isValidShortName or isValidDescription or isValidlogoUrl

  onSave: ->
    if not (0 < @state.name.trim().length <= 30)
      notifyActions.warn lang.getText 'invalid-length'
      return

    if @state.shortName.trim().length is 0 and @props.data.get('shortName')?.length > 0
      notifyActions.warn lang.getText 'invalid-length'
      return

    if @state.isErrorShortName
      return

    data =
      name: @state.name
      description: @state.description
      logoUrl: @state.logoUrl

    if @state.shortName.trim().length then data.shortName = @state.shortName

    teamActions.teamUpdate @props.data.get('_id'), data, (resp) =>
      @props.onClose()

  onSaveShortName: ->
    if @state.shortName is @props.data.get 'shortName'
      return

    if not @state.shortName.trim().length > 0
      notifyActions.warn lang.getText 'invalid-length'
      return

    data =
      shortName: @state.shortName

    teamActions.teamUpdate @props.data.get('_id'), data

  onLogoUpload: ->
    uploadUtil.handleClick
      accept: ".jpg,.jpeg,.bmp,.png"
      onCreate: @onUploaderCreate
      onSuccess: @onUploaderComplete
      onError: handlers.fileError

  onUploaderCreate: ({file}) ->
    image = FileAPI.Image file
    image.preview 200, 200
    image.get (err, imageEl) =>
      if err
        console.error err
      else
        @setState logoUrl: imageEl.toDataURL()

  onUploaderComplete: ({fileData}) ->
    @setState logoUrl: fileData.thumbnailUrl

  renderLogoEditor: ->
    div className: 'logo-editor',
      if @state.logoUrl
        style = backgroundImage: "url(#{@state.logoUrl})"
        div className: 'logo-area', style: style, onClick: @onLogoUpload
      else
        div className: 'logo-area', onClick: @onLogoUpload, @props.data.get('name')[0]

  render: ->
    readOnly = (not @props.hasPermission)
    className =  cx 'form-group', { 'is-disabled': !@props.hasPermission }

    div className: 'team-configs lm-content',
      # Team Logo: not showing in this milstore
      # div className: 'form-group',
      #   label null, lang.getText('team-logo')
      #   @renderLogoEditor()
      div className: 'form-group',
        label null, lang.getText('team-name')
        input
          type: 'text'
          className: 'form-control'
          readOnly: readOnly
          onChange: @onNameChange
          value: @state.name
          placeholder: lang.getText('team-name-placeholder')
      div className: 'form-group',
        label null, lang.getText('team-description')
        div className: 'anotated-input',
          input
            type: 'text'
            className: 'form-control'
            readOnly: readOnly
            value: @state.description
            onChange: @onDescriptionChange
            placeholder: lang.getText('team-description-placeholder')

      # team shortname component
      if !@props.hasPermission
        noscript()
      else
        div className: 'form-group',
          label {},
            lang.getText 'team-shortname'
            if @state.isErrorShortName
              span className: 'error',
                i className: 'icon icon-circle-warning'
                lang.getText 'invalid-team-shortname'
            else noscript()
          div className: 'anotated-input',
            input
              type: 'text'
              value: @state.shortName
              onChange: @onShortNameChange
              readOnly: readOnly
              className: 'form-control'
              placeholder: lang.getText 'team-shortname-placeholder'
            if not @state.isErrorShortName and @state.shortName.length
              a className: 'link-icon', onClick: @onSaveShortName, lang.getText 'generate-shorturl'
            else noscript()

      # team shorturl component (readonly)
      if @props.data.get('shortUrl')?.length > 0
        div className: 'form-group',
          label {}, lang.getText 'team-shorturl'
          LiteCopyarea
            text: (@props.data.get 'shortUrl') or ''
      else
        noscript()

      div className: className,
      if @props.hasPermission
        buttonClass = cx 'button', 'is-primary', 'is-extended',
          'is-disabled': not @needSave()
        button className: buttonClass, onClick: @onSave,
          lang.getText('save')
