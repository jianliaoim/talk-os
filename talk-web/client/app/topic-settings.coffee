React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

Permission = require '../module/permission'

query = require '../query'
lang = require '../locales/lang'

roomActions = require '../actions/room'
prefsActions = require '../actions/prefs'
notifyActions = require '../actions/notify'
topicPrefsActions = require '../actions/topic-prefs'

routerHandlers = require '../handlers/router'

mixinSubscribe = require '../mixin/subscribe'

LightModal = React.createFactory require '../module/light-modal'

div    = React.createFactory 'div'
span   = React.createFactory 'span'
p      = React.createFactory 'p'
button = React.createFactory 'button'
input  = React.createFactory 'input'

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'topic-settings'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    topic:          T.instanceOf(Immutable.Map)
    closeView:      T.func.isRequired

  getInitialState: ->
    showComfirmModal: false
    prefs: @getTopicPrefs()

  componentDidMount: ->
    @subscribe recorder, => @setState prefs: @getTopicPrefs()

  getTopicPrefs: ->
    query.topicPrefsBy(recorder.getState(), @props.topic.get('_teamId'), @props.topic.get('_id'))

  leaveTopic: ->
    routerHandlers.team @props.topic.get('_teamId')
    roomActions.roomLeave @props.topic.get('_teamId'), @props.topic.get('_id')
    @props.closeView()

  removeTopic: ->
    routerHandlers.team @props.topic.get('_teamId')
    roomActions.roomRemove @props.topic.get('_id')

    @setState showComfirmModal: false
    @props.closeView()

  archiveTopic: ->
    _notyId = query.notificationIdByTarget recorder.getState(), @props.topic.get('_teamId'), @props.topic.get('_id')

    routerHandlers.team @props.topic.get('_teamId')
    roomActions.roomArchive @props.topic.get('_id'), true, =>
      notifyActions.success lang.getText('topic-%s-archived').replace('%s', @props.topic.get('topic'))
    @props.closeView()

  onDeleteClick: ->
    @removeTopic()

  onShowConfirm: ->
    @setState showComfirmModal: true

  onCloseComfirm: ->
    @setState showComfirmModal: false

  onEmailOver: (event) ->
    event.target.select()

  # renderers

  renderConfirmModal: ->
    LightModal
      name:         'delete-topic'
      onCloseClick: @onCloseComfirm
      show:         @state.showComfirmModal

      div className: 'title', lang.getText('confirm-delete-topic')
      div className: 'menu',
        button className: 'button is-link',  onClick: @onCloseComfirm, lang.getText('cancel')
        button className: 'button is-danger confirm', onClick: @onDeleteClick, lang.getText('confirm')


  renderGuestSection: ->
    TopicGuestModePermission
      _teamId: @props.topic.get('_teamId')
      _creatorId: @props.topic.get('_creatorId')
      topic: @props.topic

  renderEmailSection: ->
    text = lang.getText('email-message-%s').replace('%s', lang.getText('this-topic'))
    email = @props.topic.get('email')

    div className: 'modal-paragraph',
      div className: 'modal-name', lang.getText('email-message')
      p className: 'muted', text
      input
        type: 'text'
        className: 'form-control', value: email
        onMouseEnter: @onEmailOver, onChange: ->

  renderActionsSection: ->
    _userId = query.userId(recorder.getState())
    isTopicCreator = @props.topic.get('_creatorId') is _userId

    div className: 'modal-paragraph',
      div className: 'topic-handle',
        div className: 'line',
          TopicArchiveButtonPermission
            _teamId: @props.topic.get('_teamId')
            _creatorId: @props.topic.get('_creatorId')
            archiveTopic: @archiveTopic
          if not (@props.topic.get('isPrivate') and isTopicCreator)
            div className: 'button is-default', onClick: @leaveTopic,
              lang.getText('topic-leave')
          TopicRemoveButtonPermission
            _teamId: @props.topic.get('_teamId')
            _creatorId: @props.topic.get('_creatorId')
            onShowConfirm: @onShowConfirm

  render: ->

    div className: 'topic-settings lm-content',
      @renderGuestSection()
      @renderEmailSection()
      unless @props.topic.get('isGeneral')
        @renderActionsSection()
      @renderConfirmModal()


TopicArchiveButtonClass = React.createClass
  displayName: 'topic-archive-button'

  propTypes:
    archiveTopic: T.func.isRequired

  render: ->
    div className: 'button is-default', onClick: @props.archiveTopic,
      lang.getText('topic-archive')


TopicRemoveButtonClass = React.createClass
  displayName: 'topic-remove-button'

  propTypes:
    onShowConfirm: T.func.isRequired

  render: ->
    div className: 'button is-danger', onClick: @props.onShowConfirm,
      lang.getText('topic-remove')


TopicGuestModeClass = require './topic-guest-mode'
TopicArchiveButtonPermission = React.createFactory Permission.create(TopicArchiveButtonClass, Permission.admin)
TopicRemoveButtonPermission = React.createFactory Permission.create(TopicRemoveButtonClass, Permission.admin)
TopicGuestModePermission = React.createFactory Permission.create(TopicGuestModeClass, Permission.admin, Permission.mode.propogate)
