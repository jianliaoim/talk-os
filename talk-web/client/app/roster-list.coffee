cx = require 'classnames'
React = require 'react'
debounce = require 'debounce'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

lang = require '../locales/lang'

mixinUser = require '../mixin/user'
mixinSubscribe = require '../mixin/subscribe'

search = require '../util/search'
detect = require '../util/detect'

Icon = React.createFactory require '../module/icon'
Avatar = React.createFactory require '../module/avatar'
UserAlias = React.createFactory require './user-alias'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ a, p, li, ul, div, span, input, noscript } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'roster-list'
  mixins: [ mixinUser, PureRenderMixin ]

  propTypes:
    _teamId: T.string.isRequired
    isStatic: T.bool
    showSearch: T.bool
    onSelect: T.func
    rosters: T.instanceOf(Immutable.List).isRequired
    selects: T.instanceOf Immutable.List
    staticSelects: T.instanceOf Immutable.List
    type: T.oneOf(['contact', 'group']).isRequired
    title: T.string
    className: T.string

  getDefaultProps: ->
    selects: Immutable.List()
    isStatic: false
    onSelect: (->)
    showSearch: true
    staticSelects: Immutable.List()

  getInitialState: ->
    searchQuery: ''
    highlightRoster: null

  componentDidMount: ->
    # Make a debounce setState method for speed up.
    # 10s debounce delay is still on the experimental.
    @debounceSetHighlightRoster = debounce @setHighlightRoster, 10

  getHeight: ->
    ITEM_HEIGHT = 40

    if @props.isStatic then ( ITEM_HEIGHT * @props.rosters.size ) else 'auto'

  ###
   * Render and relative class func of Search Module.
  ###

  handleSearchQueryChange: (event) ->
    @setState
      searchQuery: event.target.value

  renderSearch: ->
    return null if not @props.showSearch

    textKey =
      switch @props.type
        when 'group' then 'search-groups'
        when 'contact' then 'search-members'
        else 'search-for-channel'

    div className: 'search',
      input
        type: 'text'
        onChange: @handleSearchQueryChange
        className: 'input'
        placeholder: lang.getText textKey

  ###
   * Render emtpy indicator,
   * if it is a empty {@props.rosters}.
  ###

  renderEmptyIndicator: ->
    textKey =
      switch @props.type
        when 'group' then 'empty-group'
        when 'contact' then 'empty-contact'

    div className: 'empty-indicator', lang.getText textKey

  ###
   * Render and relative func of List Module,
   * rendered list is different from '@props.type'
  ###

  setHighlightRoster: (target) ->
    @setState
      highlightRoster: target

  isHighlightRoster: (target) ->
    return false if not @state.highlightRoster?

    targetId = target.get '_id'
    isExist = (id) -> id is targetId
    isHighlighter = @state.highlightRoster.get('_id') is targetId
    isStaticSelect = @props.staticSelects.some isExist

    isHighlighter and not isStaticSelect

  isSelectedRoster: (target) ->
    return false if @props.selects.size is 0

    inCollection = (item) -> item is target.get '_id'
    @props.selects.some inCollection

  handleClickRoster: (target, event) ->
    event.stopPropagation()

    if not @isUser target.get '_id'
      @props.onSelect target

  handleMouserEnterRoster: (target) ->
    @debounceSetHighlightRoster target

  handleMouserLeaveRoster: ->
    @debounceSetHighlightRoster null

  renderCell: (roster) ->
    isQuit = roster.get 'isQuit'
    isGuest = roster.get 'isGuest'
    quitText = lang.getText 'contact-quitted'
    avatarUrl = roster.get 'avatarUrl'
    isUserText = lang.getText 'me'

    isUser = @isUser roster.get '_id'
    isSelectedRoster = @isSelectedRoster roster
    isHighlightRoster = @isHighlightRoster roster

    onClick = unless isGuest then @handleClickRoster.bind(null, roster) else (->)
    onMouseEnter = => @handleMouserEnterRoster roster
    onMouseLeave = @handleMouserLeaveRoster

    li key: roster.get('_id'),
      a className: 'cell', onClick: onClick, onMouseEnter: onMouseEnter, onMouseLeave: onMouseLeave,
        if avatarUrl
          Avatar src: avatarUrl, size: 'small', shape: 'round'
        else noscript()
        UserAlias
          _teamId: @props._teamId
          _userId: roster.get('_id')
          defaultName: roster.get 'name'
        if isGuest
          span className: 'muted', lang.getText('quote-guest')
        else noscript()
        if isUser
          span className: 'muted', "(#{ isUserText })"
        else noscript()
        if isQuit
          span className: 'muted', "(#{ quitText })"
        else noscript()
        if detect.isRobot(roster)
          span className: 'muted ti ti-bot'
        else noscript()
        if isSelectedRoster
          if isHighlightRoster
            Icon color: '#FA6855', name: 'remove', size: 20
          else
            Icon color: '#67C395', name: 'tick', size: 20
        else noscript()

  renderList: (rosters) ->
    listStyle =
      height: @getHeight()

    ul className: 'list thin-scroll', style: listStyle,
      if rosters.size > 0
        rosters.map (roster) =>
          @renderCell roster
      else
        @renderEmptyIndicator()

  ###
   * Filter roster with '@state.searchQuery'
  ###

  filterRosters: (searchQuery, rosters, type) ->
    # return original rosters if '@state.searchQuery' is empty
    return rosters if searchQuery.length is 0

    opt =
      if type is 'contact'
        getAlias: (_id) =>
          query.contactAliasBy(recorder.getState(), @props._teamId, _id)
      else
        {}

    search.inKeyword rosters, searchQuery, opt

  render: ->
    { type, rosters } = @props
    searchQuery = @state.searchQuery.trim()
    rosters = @filterRosters searchQuery, rosters, type

    div className: cx('roster-list', @props.className),
      @renderTitle()
      @renderSearch()
      @renderList rosters

  renderTitle: ->
    return null if not @props.title?

    p className: 'title', @props.title
