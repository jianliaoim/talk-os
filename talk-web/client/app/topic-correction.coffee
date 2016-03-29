React = require 'react'
Immutable = require 'immutable'

lang = require '../locales/lang'

span = React.createFactory 'span'

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'topic-correction'

  propTypes:
    topic: T.instanceOf(Immutable.Map)

  isGeneral: ->
    @props.topic.get('isGeneral')

  render: ->
    name =
      if @isGeneral()
        lang.getText('room-general')
      else
        @props.topic.get('topic')
    span className: 'name text-overflow', name
