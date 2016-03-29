React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

eventBus = require '../event-bus'

lang = require '../locales/lang'

roomActions = require '../actions/room'
notifyActions = require '../actions/notify'

div    = React.createFactory 'div'
span   = React.createFactory 'span'
a      = React.createFactory 'a'
button = React.createFactory 'button'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'topic-join'
  mixins: [PureRenderMixin]

  propTypes:
    topic: T.object.isRequired

  onJoinClick: ->
    roomActions.roomJoin @props.topic.get('_teamId'), @props.topic.get('_id'), (resp) ->
      notifyActions.success lang.getText('joined-topic')
      eventBus.emit 'dirty-action/new-message'

  render: ->
    [text1, text2] = lang.getText('previewing-topic').split('%s')

    div className: 'topic-join',
      div className: 'mask'
      div className: 'box',
        div className: 'text',
          text1
          span className: 'name',
            '#'
            @props.topic.get('topic')
          text2
        button className: 'button is-primary is-small', onClick: @onJoinClick,
          lang.getText('join')
