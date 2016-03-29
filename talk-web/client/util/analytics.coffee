cookie = require 'cookie_js'
config = require '../config'

exports.gaEvent = (category, action, label, value) ->
  if __DEV__
    console.info 'ga event:', category, action, label, value
  window.ga? 'send',
    hitType: 'event',
    eventCategory: category,
    eventAction: action,
    eventLabel: label
    eventValue: value

exports.gaTiming = (category, variable, value) ->
  window.ga? 'send',
    hitType: 'timing'
    timingCategory: category
    timingVar: variable
    timingValue: value

exports.mixpanel = (event, properties) ->
  if __DEV__
    console.info 'mixpanel event:', event, properties
  window.mixpanel?.track event, properties

exports.event = (category, action, label, value) ->
  properties =
    category: category
    label: label
    value: value
  exports.mixpanel action, properties
  exports.gaEvent category, action, label, value

# methods

getAssetsTime = ->
  timing = window.performance.timing
  assetsTime = timing.domLoading - timing.navigationStart

getRenderTime = ->
  timing = window.performance.timing
  renderTime = (new Date).valueOf() - timing.domLoading

# Safari 8.4 does not support http://caniuse.com/#feat=nav-timing
exports.readRapidBootPerfs = ->
  return unless window.performance?
  exports.gaTiming 'loading', 'assets', getAssetsTime()
  exports.gaTiming 'loading', 'rapid boot', getRenderTime()

exports.readLoadingPerfs = ->
  return unless window.performance?
  exports.gaTiming 'loading', 'assets', getAssetsTime()
  exports.gaTiming 'loading', 'full load', getRenderTime()

exports.compareRequireCost = (startTime, label) ->
  now = (new Date).valueOf()
  cost = now - startTime
  if cost > 20
    # suppose dependencies from remote server cost more than 20ms
    exports.gaTiming 'async require', label, cost

# super properties for mixpanel
exports.registerSuperProperties = ->
  if typeof window isnt 'undefined'
    platform = switch
      # https://github.com/atom/electron/issues/2288
      when window.process?.versions?.electron? then 'Electron'
      else 'Web'
    window.mixpanel?.register
      version: config.version
      serverEnv: config.serverEnv
      platform: platform

# tracked events
# https://www.teambition.com/project/52ce03c161d25a961b002cd1/posts/post/56c161e399ee3a7d039dbe69

# category web app
exports.trackAppLoaded = ->
  # 监控应用初始化
  exports.event 'web app', 'initial loaded'

# category retention 活跃度
exports.alive = -> exports.event 'retention', 'alive'

# category rookie

exports.updateAvatar = -> exports.gaEvent 'rookie', 'update avatar'

# category switch teams

exports.viewTeams = -> exports.event 'switch teams', 'visit teams'
exports.chooseTeam = -> exports.gaEvent 'switch teams', 'choose team'
exports.createTeam = -> exports.gaEvent 'switch teams', 'create team'
exports.scanTeam = -> exports.event 'switch teams', 'scan team' # phone only event
exports.syncTeam = -> exports.event 'switch teams', 'sync team'
exports.settingUser = -> exports.gaEvent 'switch teams', 'setting user' # phone only event

# category start talk

exports.clickIdeaStory = -> exports.gaEvent 'start talk', 'click idea story'
exports.createIdeaStory = -> exports.gaEvent 'start talk', 'create idea story'
exports.clickFileStory = -> exports.gaEvent 'start talk', 'click file story'
exports.createFileStory = -> exports.gaEvent 'start talk', 'create file story'
exports.clickLinkStory = -> exports.gaEvent 'start talk', 'click link story'
exports.createLinkStory = -> exports.gaEvent 'start talk', 'create link story'
exports.clickChatFromStory = -> exports.gaEvent 'start talk', 'click chat', 'from story'
exports.clickChatFromRoom = -> exports.gaEvent 'start talk', 'click chat', 'from room'
exports.enterChatFromStory = -> exports.gaEvent 'start talk', 'enter chat', 'from story'
exports.enterChatFromRoom = -> exports.gaEvent 'start talk', 'enter chat', 'from room'
exports.clickRoom = -> exports.gaEvent 'start talk', 'click room'
exports.enterRoom = -> exports.gaEvent 'start talk', 'enter room'

# category page elements

exports.clickAtButton = -> exports.gaEvent 'page elements', 'click at button', 'from editor'
exports.focusQuickSearch = -> exports.gaEvent 'page elements', 'focus quick search'
exports.switchChatTargetFromQuickSearch = (type) -> exports.gaEvent 'page elements', 'switch channel - quick search', type
exports.switchChatTargetFromRecentList = (type) -> exports.gaEvent 'page elements', 'switch channel - recent list', type
exports.switchChatTargetFromContact = -> exports.gaEvent 'page elements', 'switch channel - contact'
exports.switchChatTargetFromSearch = -> exports.gaEvent 'page elements', 'switch channel - search'
exports.openIntegrationFromTeam = -> exports.gaEvent 'page elements', 'open integration', 'from team'
exports.openIntegrationFromRoom = -> exports.gaEvent 'page elements', 'open integration', 'from room'
exports.openAddService = -> exports.event 'page elements', 'open add service'
exports.openCustomIntegration = -> exports.gaEvent 'page elements', 'open custom integration'
exports.openEditIntegration = -> exports.gaEvent 'page elements', 'open edit integration'

# category login (most events in this category are written in talk-account)

exports.loginSucc = (label) -> exports.event 'login', 'login succ', label
exports.registerSucc = (label) -> exports.event 'login', 'register succ', label
exports.directLogin = -> exports.event 'login', 'direct login succ'

# category modal(track modal usages)

exports.modalFileSwitchLeft = -> exports.event 'modal', 'file switch left'
exports.modalFileSwitchRight = -> exports.event 'modal', 'file switch right'

# category read message

categoryReadMessage = (action) -> exports.event 'read message', action

exports.viewFile = -> categoryReadMessage 'view file'
exports.viewImage = -> categoryReadMessage 'view image'
exports.viewOverlayImage = -> categoryReadMessage 'view overlay image'
exports.downloadFile = -> categoryReadMessage 'download file'
exports.viewLink = -> categoryReadMessage 'view link'
exports.viewPost = -> categoryReadMessage 'view post'
exports.viewSnippet = -> categoryReadMessage 'view snippet'
exports.editMessage = -> categoryReadMessage 'edit message'

# category navigate

exports.startTalk = -> exports.gaEvent 'navigate', 'start talk'
exports.openSearch = -> exports.event 'navigate', 'open search'
exports.openOverview = -> exports.event 'navigate', 'open overview'

# category team

exports.enterTeam = -> exports.event 'team', 'enter team'

# category count

countMessages = 0
exports.trackMessageSent = -> countMessages += 1

exports.countChannelMessages = ->
  exports.gaEvent 'count', 'channel messages', undefined, countMessages
  countMessages = 0

# special method, handles trackingPage and trackingPageTime passed from talk-account via cookie

exports.detectTrackingInfoFromAccount = ->
  trackingPage = cookie.get('trackingPage')
  trackingPageLabel = cookie.get('trackingPageLabel')
  trackingPageTime = cookie.get('trackingPageTime')

  if trackingPage? and trackingPageTime?
    duration = window.performance.timing.navigationStart - trackingPageTime
    switch trackingPage
      when 'login'
        exports.loginSucc(trackingPageLabel)
        exports.gaTiming 'login', 'login succ', duration
      when 'register'
        exports.registerSucc(trackingPageLabel)
        exports.gaTiming 'login', 'register succ', duration
      when 'direct login'
        exports.directLogin()
        exports.gaTiming 'login', 'direct login succ', duration
    # actually remove cookie
    cookieConfigs =
      domain: config.cookieDomain, path: '/', expires: -1
    cookie.set 'trackingPage', null, cookieConfigs
    cookie.set 'trackingPageLabel', null, cookieConfigs
    cookie.set 'trackingPageTime', null, cookieConfigs
