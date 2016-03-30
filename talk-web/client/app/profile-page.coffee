cx = require 'classnames'
React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

if typeof window isnt 'undefined'
  cookie = require 'cookie_js'

query = require '../query'
config = require '../config'

prefsActions = require '../actions/prefs'
notifyActions = require '../actions/notify'
accountActions = require '../actions/account'

handlers = require '../handlers'
routerHandlers = require '../handlers/router'

mixinSubscribe = require '../mixin/subscribe'

api = require '../network/api'

lang = require '../locales/lang'

ProfileName = React.createFactory require './profile-name'
ProfileAvatar = React.createFactory require './profile-avatar'

Icon = React.createFactory require '../module/icon'
LightModal = React.createFactory require '../module/light-modal'

PureRenderMixin = require 'react-addons-pure-render-mixin'
{ a, i, div, img, span, input, label } = React.DOM
T = React.PropTypes

COOKIE_CONFIG =
  domain: config.cookieDomain, expires: 7, path: '/'

module.exports = React.createClass
  displayName: 'profile-page'
  mixins: [mixinSubscribe, PureRenderMixin]

  getInitialState: ->
    user: @getUser()
    prefs: @getPrefs()
    showModalName: false
    showModalAvatar: false

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        user: @getUser()
        prefs: @getPrefs()

  getUser: ->
    query.user(recorder.getState())

  getPrefs: ->
    query.prefs(recorder.getState())

  getLang: ->
    prefs = query.prefs(recorder.getState())
    prefs?.get('language') or 'zh'

  onBack: ->
    routerHandlers.back()

  onModalShow: (state) -> @setState "#{state}": true

  onModalClose: (state) -> @setState "#{state}": false

  onPrefsChange: (data, event) ->
    event.preventDefault()
    prefsActions.prefsUpdate data

  onAccountClick: (event) ->
    event.preventDefault()
    cookie.set 'lang', @getLang(), COOKIE_CONFIG
    window.open "#{config.accountUrl}/user/accounts"

  onLanguageZh: (event) ->
    cookie.set 'lang', 'zh', COOKIE_CONFIG
    @onPrefsChange language: 'zh', event

  onLanguageEn: (event) ->
    cookie.set 'lang', 'en', COOKIE_CONFIG
    @onPrefsChange language: 'en', event

  onLanguageZhTw: (event) ->
    cookie.set 'lang', 'zh-tw', COOKIE_CONFIG
    @onPrefsChange language: 'zh-tw', event

  renderModalAvatar: ->
    LightModal
      name: 'edit-avatar'
      show: @state.showModalAvatar
      title: lang.getText 'edit-avatar'
      onCloseClick: (@onModalClose.bind null, 'showModalAvatar'),
        ProfileAvatar
          avatarUrl: @state.user.get('avatarUrl')

  renderModalName: ->
    LightModal
      name: 'edit-name'
      show: @state.showModalName
      title: lang.getText 'edit-name'
      onCloseClick: (@onModalClose.bind null, 'showModalName'),
        ProfileName
          name: @state.user.get('name')
          onComplete: (@onModalClose.bind null, 'showModalName')

  renderProfileSection: ->
    div className: 'section',
      div className: 'title', lang.getText 'personal-profile'
      div className: 'item',
        span className: 'item-label', lang.getText 'avatar'
        span className: 'item-content',
          span className: 'avatar-url', style: backgroundImage: "url(#{ @state.user.get('avatarUrl') })"
        span className: 'item-action', onClick: (@onModalShow.bind null, 'showModalAvatar'),
          lang.getText 'edit'
      div className: 'item',
        span className: 'item-label', lang.getText 'name'
        span className: 'item-content', @state.user.get('name')
        span className: 'item-action', onClick: (@onModalShow.bind null, 'showModalName'),
          lang.getText 'edit'

  renderAccountSection: ->
    div className: 'section',
      div className: 'title', lang.getText 'account-binding'
      div className: 'as-body',
        span className: 'button is-primary is-small', onClick: @onAccountClick,
          lang.getText('manageAccounts')

  renderPrefsSection: ->
    notifyAll = desktopNotification: true, notifyOnRelated: false
    notifyNone = desktopNotification: false, notifyOnRelated: false
    notifyRelated = desktopNotification: true, notifyOnRelated: true

    div className: 'section',
      div className: 'title', lang.getText 'display-and-notification'
      div className: 'item',
        span className: 'item-label', lang.getText 'language'
        span className: 'item-content',
          label className: 'line', onClick: @onLanguageZh,
            input type: 'radio', readOnly: true, checked: (@getLang() is 'zh')
            span null, '简体中文'
          label className: 'line', onClick: @onLanguageEn,
            input type: 'radio', readOnly: true, checked: (@getLang() is 'en')
            span null, 'English'
          label className: 'line', onClick: @onLanguageZhTw,
            input type: 'radio', readOnly: true, checked: (@getLang() is 'zh-tw')
            span null, '繁體中文'
      div className: 'item',
        span className: 'item-label', lang.getText 'message-style'
        span className: 'item-content',
          label className: 'line', onClick: (@onPrefsChange.bind null, displayMode: 'default'),
            input type: 'radio', readOnly: true, checked: (@state.prefs.get('displayMode') is 'default')
            span null, lang.getText 'default-default-style'
          label className: 'line', onClick: (@onPrefsChange.bind null, displayMode: 'slim'),
            input type: 'radio', readOnly: true, checked: (@state.prefs.get('displayMode') is 'slim')
            span null, lang.getText 'slim-default-style'
      div className: 'item',
        span className: 'item-label', lang.getText 'desktop-notifications'
        span className: 'item-content',

          label className: 'line', onClick: @onPrefsChange.bind(null, notifyAll),
            input type: 'radio', readOnly: true, checked: (@state.prefs.get('desktopNotification') and not @state.prefs.get('notifyOnRelated'))
            span null, lang.getText 'notify-all'

          label className: 'line', onClick: @onPrefsChange.bind(null, notifyRelated),
            input type: 'radio', readOnly: true, checked: (@state.prefs.get('desktopNotification') and @state.prefs.get('notifyOnRelated'))
            span null, lang.getText 'notify-related'

          label className: 'line', onClick: @onPrefsChange.bind(null, notifyNone),
            input type: 'radio', readOnly: true, checked: (not @state.prefs.get('desktopNotification') and not @state.prefs.get('notifyOnRelated'))
            span null, lang.getText 'turn-off'
      div className: 'item',
        span className: 'item-label', lang.getText 'email-notifications'
        span className: 'item-content',
          label className: 'line', onClick: @onPrefsChange.bind(null, emailNotification: true),
            input type: 'radio', readOnly: true, checked: @state.prefs.get 'emailNotification'
            lang.getText 'turn-on'
          label className: 'line', onClick: @onPrefsChange.bind(null, emailNotification: false),
            input type: 'radio', readOnly: true, checked: not @state.prefs.get 'emailNotification'
            lang.getText 'turn-off'

  render: ->
    div className: 'profile-page',
      div className: 'header flex-horiz flex-vcenter',
        Icon name: 'arrow-left', className: 'to-back', size: 24, onClick: @onBack
        span className: 'flex-fill title', lang.getText 'profile-page'
      div className: 'content thin-scroll',
        @renderProfileSection()
        @renderAccountSection()
        @renderPrefsSection()

      @renderModalAvatar()
      @renderModalName()
