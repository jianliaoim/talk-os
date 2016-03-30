React = require 'react'
recorder = require 'actions-recorder'
uploadUtil  = require '../util/upload'

if typeof window isnt 'undefined'
  FileAPI = require 'fileapi'

query = require '../query'

lang = require '../locales/lang'
config = require '../config'
handlers = require '../handlers'

userActions = require '../actions/user'

div = React.createFactory 'div'
i = React.createFactory 'i'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'profile-avatar'

  propTypes:
    avatarUrl: T.string.isRequired

  getInitialState: ->
    avatarUrl: @props.avatarUrl

  onUploaderCreate: ({file}) ->
    image = FileAPI.Image file
    image.preview 200, 200
    image.get (err, imageEL) =>
      if err
        console.error err
      else
        @setState avatarUrl: imageEL.toDataURL()

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

  render: ->
    avatarStyle =
      if @props.avatarUrl?.length
        backgroundImage: "url(#{ @state.avatarUrl })"
      else undefined

    div className: 'profile-avatar',
      div className: 'trigger', ref: 'trigger', style: avatarStyle, onClick: @onFileClick,
        i className: 'ti ti-camera'
