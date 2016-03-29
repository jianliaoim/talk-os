React = require 'react'
assign = require 'object-assign'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div = React.createFactory 'div'

tagActions = require '../actions/tag'

mixinFileQueue = require '../mixin/file-queue'
mixinSubscribe = require '../mixin/subscribe'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-queue-tag'
  mixins: [mixinFileQueue, mixinSubscribe, PureRenderMixin]

  propTypes:
    # used in mixin
    messages: T.instanceOf(Immutable.List)
    onClose: T.func.isRequired
    attachment: T.instanceOf(Immutable.Map)
    # used in component
    _teamId: T.string.isRequired
    _roomId: T.string
    _toId: T.string
    query: T.object

  getInitialState: ->
    initPage = @props.query?.page - 1
    page: initPage or 1

  requestBefore: (success) ->
    success Immutable.List()

  requestAfter: (success) ->
    data = assign {}, @props.query,
      page: @state.page + 1
      _maxId: @props.messages.last()?.get('_id')

    if @props.query?
      tagActions.searchTagged data,
        (resp) =>
          @setState page: @state.page + 1

  render: ->
    @renderQueue()
