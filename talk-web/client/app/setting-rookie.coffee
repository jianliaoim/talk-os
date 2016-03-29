cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
FileAPI = require 'fileapi'

uploadUtil  = require '../util/upload'
analytics = require '../util/analytics'

query = require '../query'
config = require '../config'
handlers = require '../handlers'

userActions = require '../actions/user'
routerHandlers = require '../handlers/router'

lang = require '../locales/lang'

div = React.createFactory 'div'
i = React.createFactory 'i'
input = React.createFactory 'input'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'setting-rookie'
  mixins: []

  getInitialState: ->
    avatarName: ''
    avatarUrl: query.user(recorder.getState())?.get('avatarUrl') or ''

  onNameChange: (event) ->
    avatarName = event.target.value
    @setState
      avatarName: avatarName

  onRookieComplete: ->
    _userId = query.userId(recorder.getState())
    userActions.userUpdate _userId,
      avatarUrl: @state.avatarUrl
      name: @state.avatarName
    , ->
      routerHandlers.settingTeams()

  onUploaderCreate: ({file}) ->
    image = FileAPI.Image file
    image.preview 200, 200
    image.get (err, imageEL) =>
      if err
        console.error err
      else
      @setState avatarUrl: imageEL.toDataURL()
    analytics.updateAvatar()

  onUploaderComplete: ({fileData}) ->
    _userId = query.userId(recorder.getState())
    userActions.userUpdate _userId, avatarUrl: fileData.thumbnailUrl
    @setState avatarUrl: fileData.thumbnailUrl

  onFileClick: (event) ->
    uploadUtil.handleClick
      accept: ".jpg,.jpeg,.bmp,.png"
      onCreate: @onUploaderCreate
      onSuccess: @onUploaderComplete
      onError: handlers.fileError

  renderUpload: ->

    avatarStyle =
      if @state.avatarUrl?.length
        backgroundImage: "url(#{ @state.avatarUrl })"
      else
        {}
    div className: 'data-avatar', style: avatarStyle, onClick: @onFileClick,
      i className: 'icon icon-camera'

  render: ->
    buttonClassName = cx
      'button': true
      'is-disabled': @state.avatarName.length is 0

    div className: 'setting-rookie setting-wrapper',
      div className: 'header', lang.getText 'setting-rookie'
      div className: 'content',
        @renderUpload()
        div className: 'data-name',
          input
            className: 'input'
            placeholder: lang.getText 'enter-your-name'
            defaultValue: @state.avatarName
            onChange: @onNameChange
        div className: buttonClassName, onClick: @onRookieComplete, lang.getText 'complete'
