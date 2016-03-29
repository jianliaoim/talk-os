React = require 'react'
assign = require 'object-assign'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div = React.createFactory 'div'

favoriteActions = require '../actions/favorite'

mixinFileQueue = require '../mixin/file-queue'
mixinSubscribe = require '../mixin/subscribe'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-queue-favorite'
  mixins: [mixinFileQueue, mixinSubscribe, PureRenderMixin]

  propTypes:
    # used in mixin
    messages: T.instanceOf(Immutable.List)
    onClose: T.func.isRequired
    cursor: T.instanceOf(Immutable.Map)
    # used in component
    _teamId: T.string.isRequired
    _roomId: T.string
    _toId: T.string
    query: T.object

  getInitialState: ->
    page: @props.query.page - 1

  requestBefore: (success) ->
    success Immutable.List()

  requestAfter: (success) ->
    data = assign {}, @props.query,
      page: @state.page + 1

    if @props.query?
      favoriteActions.searchFavorite data,
        (resp) =>
          @setState page: @state.page + 1

  render: ->
    @renderQueue()
