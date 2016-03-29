cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'
handlers = require '../handlers'

roomActions = require '../actions/room'
notifyActions = require '../actions/notify'
accountActions = require '../actions/account'

lang = require '../locales/lang'

mixinModal = require '../mixin/modal'
mixinSubscribe = require '../mixin/subscribe'

permission = require '../module/permission'

url = require '../util/url'
time = require '../util/time'

TopicDetails = React.createFactory require './topic-details'
RosterManagement = React.createFactory require './roster-management'
TalkDownload = React.createFactory require './talk-download'

LiteModal = React.createFactory require('react-lite-layered').Modal
SlimModal = React.createFactory require './slim-modal'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ a, p, h2, div, span, button } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'topic-banner'
  mixins: [mixinModal, mixinSubscribe, PureRenderMixin]

  propTypes:
    preview: T.bool
    topic: T.instanceOf(Immutable.Map)
    creator: T.instanceOf(Immutable.Map)

  getDefaultProps: ->
    preview: false

  getInitialState: ->
    alias: @getAlias()
    displayMode: @getDisplayMode()
    showMembers: false
    showTopicSettings: false

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        alias: @getAlias()
        displayMode: @getDisplayMode()

  getDisplayMode: ->
    prefs = query.prefs(recorder.getState())
    if prefs
      prefs.get('displayMode')
    else 'default'

  getAlias: ->
    alias = query.contactPrefsBy(recorder.getState(), @props.topic.get('_teamId'), @props.creator.get('_id'))?.get('alias')

  handleSubmitMember: (memberIds) ->
    prevIds = @props.topic.get '_memberIds'
    nextIds = memberIds

    data = @onExtractData prevIds, nextIds
    if data
      channelId = @props.topic.get '_id'
      roomActions.roomUpdate channelId, data.toJS()

  onExtractData: (prevIds, nextIds) ->
    if not prevIds.toSet().equals(nextIds.toSet())
      data = Immutable.Map()
      addMembers = Immutable.List()
      removeMembers = Immutable.List()

      nextIds.forEach (nextId) ->
        if not prevIds.includes nextId
          addMembers = addMembers.push nextId

      prevIds.forEach (prevId) ->
        if not nextIds.includes prevId
          removeMembers = removeMembers.push prevId

      if addMembers.size > 0
        data = data.set 'addMembers', addMembers

      if removeMembers.size > 0
        data = data.set 'removeMembers', removeMembers

      return data

    return false

  onGuestClick: ->
    @setState showTopicSettings: true

  onGuestClose: ->
    @setState showTopicSettings: false

  onInteClick: ->
    accountActions.fetch()
    handlers.router.integrations @props.topic.get('_teamId'), @props.topic.get('_id')

  # renderers

  renderGuideText: ->
    text = 'room-main-created'
    if @props.topic.get('isGeneral') then text = 'room-main-beginning'

    lang
    .getText text
    .replace '{{name}}', @state.alias or @props.creator.get('name') or lang.getText 'contact-quitted'
    .replace '{{time}}', time.calendar(@props.topic.get('createdAt'))
    .replace '{{purpose}}', @props.topic.get('purpose')

  renderActions: ->
    div className: 'line',
      unless @props.topic.get('isGeneral')
        button className: 'button is-primary add-members', onClick: @onOpenModal,
          span className: 'icon icon-add-user'
          lang.getText 'invite-friends'
      button className: 'button is-primary add-integrations', onClick: @onInteClick,
        span className: 'icon icon-config'
        lang.getText 'add-integrations'
      button className: 'button is-primary guest-mode', onClick: @onGuestClick,
        span className: 'icon icon-eye'
        lang.getText 'guest-mode'

  renderTopicSettings: ->
    LiteModal
      name: 'topic-settings'
      show: @state.showTopicSettings
      title: lang.getText 'topic-details'
      onCloseClick: @onGuestClose
      TopicDetails
        topic: @props.topic
        closeView: @onGuestClose
        initialTab: 'topic-settings'

  renderMembers: ->
    SlimModal
      name: 'channel-member'
      show: @state.showModal
      title: lang.getText('invite-members')
      onClose: @onCloseModal
      RosterManagementPermission
        _teamId: @props.topic.get '_teamId'
        _creatorId: @props.topic.get '_creatorId'
        onClose: @onCloseModal
        isPublic: not @props.topic.get 'isPrivate'
        onSubmit: @handleSubmitMember
        selectedContacts: @props.topic.get '_memberIds'

  render: ->
    name = @props.topic.get 'topic'
    if @props.topic.get 'isGeneral'
      name = lang.getText 'start-using-talk'

    classNameDisplayMode = cx
      'display-default': (@state.displayMode is 'default')
      'display-slim': (@state.displayMode isnt 'default')

    div className: 'topic-banner',
      div className: classNameDisplayMode,
        div className: 'display', 'Hi,'
        div className: 'display', @renderGuideText()
        if not @props.preview
          @renderActions()
      if @props.topic.get('isGeneral')
        div className: 'clients',
          span className: 'muted', lang.getText 'room-main-download'
          TalkDownload()
      # modals
      @renderTopicSettings()
      @renderMembers()

###
 * Permission module below
###

PermissionFactory = (ReactClass) ->
  React.createFactory permission.create ReactClass,
    permission.member
    permission.mode.propogate

RosterManagementPermission = PermissionFactory React.createClass
  displayName: 'roster-management-permission'

  propTypes:
    isPublic: T.bool
    onClose: T.func.isRequired
    onSubmit: T.func.isRequired
    selectedContacts: T.instanceOf(Immutable.List).isRequired

  render: ->
    isPublic = @props.isPublic
    isSuperRole = @props.role in permission.superRole
    isRemovable = not isPublic and isSuperRole

    RosterManagement
      _teamId: @props._teamId
      onClose: @props.onClose
      onSubmit: @props.onSubmit
      isRemovable: isRemovable
      selectedContacts: @props.selectedContacts
