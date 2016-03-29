React = require 'react'
urlParse = require 'url-parse'
Immutable = require 'immutable'

lang = require '../locales/lang'

time = require '../util/time'
detect = require '../util/detect'

{ div, hr } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'channel-banner'

  propsTypes:
    channel: T.instanceOf(Immutable.Map).isRequired

  renderGuideText: ->
    lang.getText('channel-main-created')
    .replace '{{name}}', @props.channel.getIn(['creator', 'name'])
    .replace '{{time}}', time.calendar(@props.channel.get('createdAt'))

  renderDescrption: ->
    return null unless @props.channel.get('category') is 'topic'
    div null,
      hr null
      div className: 'description', @props.channel.get('text')

  render: ->
    return null if @props.channel.isEmpty()

    creator = @props.channel.get('creator').get('name')
    createdAt = time.calendar @props.channel.get('createdAt')

    div className: 'channel-banner',
      div className: 'display', 'Hi'
      div className: 'display', @renderGuideText()
      @renderDescrption()
