React = require 'react'
cx = require 'classnames'
filesize = require 'filesize'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang      = require '../locales/lang'

RelativeTime = React.createFactory require '../module/relative-time'
UserAlias =  React.createFactory require './user-alias'
FileAudio = React.createFactory require './file-audio'
FileDefault = React.createFactory require './file-default'
FileImage = React.createFactory require './file-image'
FileText = React.createFactory require './file-text'
FileInfo = React.createFactory require './file-info'

a = React.createFactory 'a'
div = React.createFactory 'div'
span = React.createFactory 'span'

l = lang.getText
T = React.PropTypes

module.exports = React.createClass
  displayName: 'story-viewer'
  mixins: [PureRenderMixin]

  propTypes:
    story: T.instanceOf(Immutable.Map).isRequired
    onClose: T.func

  getFile: ->
    @props.story.get('data')

  renderTitle: ->
    file = @getFile()
    return null if not file
    div className: 'title',
      file.get('fileName')
      span className: 'muted', " (#{filesize file.get('fileSize'), unix: true})"

  renderFileTypes: ->
    file = @getFile()
    return null if not file
    element =
      switch
        when file.get('fileCategory') is 'image' and file.get('thumbnailUrl')
          FileImage
            file: file
            key: file.get('_id')
        when file.get('fileCategory') is 'file'
          FileText
            file: file
            key: file.get('_id')
        else FileDefault file: file
    div className: 'file-container', element

  renderSender: ->
    UserAlias
      _teamId: @props.story.get('_teamId')
      _userId: @props.story.get('_creatorId')
      defaultName: @props.story.getIn(['creator', 'name'])
      replaceMe: true

  renderContent: ->
    div className: 'content',
      @renderSender()
      l('comma')
      RelativeTime data: @props.story.get('createdAt')

  render: ->
    div className: 'file-queue story-viewer',
      span className: 'button-close icon icon-remove', onClick: @props.onClose
      div className: 'body',
        @renderFileTypes()
      div className: 'file-info',
        div className: 'info',
          @renderTitle()
        @renderContent()
