React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

query = require '../query'
lang    = require '../locales/lang'

mixinSubscribe = require '../mixin/subscribe'

roomActions = require '../actions/room'

TopicSettings = React.createFactory require '../app/topic-settings'
SwitchTabs    = React.createFactory require('react-lite-misc').SwitchTabs

Permission = require '../module/permission'
TopicConfigsClass = require '../app/topic-configs'
TopicConfigsPermission = React.createFactory Permission.create(TopicConfigsClass, Permission.admin, Permission.mode.propogate)

div = React.createFactory 'div'

T = React.PropTypes

tabs = ['topic-configs', 'topic-settings']

module.exports = React.createClass
  displayName: 'topic-details'
  mixins: [mixinSubscribe, PureRenderMixin]

  propTypes:
    topic:      T.instanceOf(Immutable.Map)
    closeView:  T.func.isRequired
    initialTab: T.oneOf(tabs)

  getInitialState: ->
    tab: @props.initialTab or tabs[0]

  onTabClick: (tab) ->
    @setState tab: tab

  onSave: (data, cb) ->
    roomActions.roomUpdate @props.topic.get('_id'), data, (resp) =>
      cb? resp
      @props.closeView()

  render: ->
    div className: 'topic-details',
      SwitchTabs
        data: tabs, tab: @state.tab
        onTabClick: @onTabClick
        getText: lang.getText
      switch @state.tab
        when 'topic-configs'
          TopicConfigsPermission
            _teamId: @props.topic.get('_teamId')
            _creatorId: @props.topic.get('_creatorId')
            topic: @props.topic
            saveConfigs: @onSave
        when 'topic-settings'
          TopicSettings
            topic: @props.topic
            closeView: @props.closeView
