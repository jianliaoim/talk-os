React = require 'react'
assign = require 'object-assign'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

div = React.createFactory 'div'

searchActions = require '../actions/search'

mixinFileQueue = require '../mixin/file-queue'
mixinSubscribe = require '../mixin/subscribe'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'file-queue-collection'
  mixins: [mixinFileQueue, mixinSubscribe, PureRenderMixin]

  propTypes:
    # used in mixin
    messages: T.instanceOf(Immutable.List)
    onClose: T.func.isRequired
    cursor: T.instanceOf(Immutable.Map)
    # used in component
    query: T.object
    isFavorite: T.bool

  getDefaultProps: ->
    isFavorite: false

  getInitialState: ->
    if @props.query?.page
      initPage = @props.query.page - 1
    page: initPage or 1

  requestBefore: (success) ->
    success Immutable.List()

  requestAfter: (success) ->
    if @props.query?
      data = assign {}, @props.query,
        page: @state.page + 1
        _maxId: @props.messages.last()?.get('_id')

      searchActions.collection data,
        (resp) =>
          @setState page: @state.page + 1
          success resp.get('messages')

  render: ->
    @renderQueue()
