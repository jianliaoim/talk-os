
Immutable = require 'immutable'

defaultConfig = require '../config/default'
loadingSentences = require './util/loading-sentences'

exports.device = Immutable.fromJS
  _teamId: null
  disconnection: false
  # isTuned will be set to true when the scrollbar is
  # at the bottom of the message scroll timeline
  # this is used for message timeline auto-scroll when we are
  # receiving new messages
  isTuned: false
  isFocused: true
  lastChannel: null
  loadingStack: []
  viewingAttachment: null
  isClearingUnread: {} # _teamId, _channelId, isClearingUnread
  inboxLoadStatus: {} # _teamId: Boolean
  editMessageId: null

exports.drafts = Immutable.fromJS
  post: {} # "#{_teamId}+#{_channelId}" => {title, text}
  draft: {} # "#{_teamId}+#{_channelId}" => string
  story: {} # _teamid
  snippet: {} # "#{_teamId}+#{_channelId}" => {title, text, codeType}
  activeMarkdown: true

exports.settings = Immutable.fromJS
  isLoggedIn: false
  showDrawer: false
  showFavorites: false
  showInteBanner: true
  showCollection: false
  showTag: false
  teamFootprints: {} # _teamId => unix time
  foldedContacts: {} # [_teamId, _contactId]
  emojiCounts: {}

exports.router = Immutable.fromJS
  name: 'home'
  data: {}
  query: {}

exports.database = Immutable.fromJS
  # server information
  config: defaultConfig
  # database
  tags: {} # _teamId
  user: {} # object
  intes: {} # _teamId
  prefs: {} # object
  teams: {} # _teamId
  groups: {} # _teamId
  router: exports.router
  topics: {} # _teamId
  members: {} # [_teamId, _roomId]
  stories: {} # { _teamId: [] }
  accounts: [] # array
  contacts: {} # _teamId
  messages: {} # [_teamId, _channelId]
  favorites: {} # _teamId
  activities: {} # _teamId, {stage: loading|partial|entire, data}. Notice: this field is in new format with `stage` mark.
  topicPrefs: {} # [_teamId, _roomId]
  invitations: {} # _teamId
  contactPrefs: {} # [_teamId, _contactId]
  leftContacts: {} # _teamId
  notifications: {} # { _teamId: [] }
  archivedTopics: {} # _teamId
  # user states
  device: exports.device
  drafts: exports.drafts
  notices: {} # _noticeId
  settings: exports.settings
  inteSettings: {} # object
  bannerNotices: {} # object
  foldedContacts: {} # [_teamId, _contactId], localStorage 'talk-storage:folded-contacts'
  # search results
  favResults: [] # array
  fileMessages: {} # [_teamId, _channelId]
  linkMessages: {} # [_teamId, _channelId]
  postMessages: {} # [_teamId, _channelId]
  snippetMessages: {} # [_teamId, _channelId]
  searchMessages: [] # array
  taggedResults: [] # array
  taggedMessages: [] # array
  thirdParties: {} # refer
  mentionedMessages: [] # [_teamId]
  loadingSentences: loadingSentences.list
  # 持久化数据
  # timelineList 从团队创建日期开始到今天的时间分割数据
  timelineList: {}

  teamSubscribe: {}

exports.fakeEmptyMessage = Immutable.fromJS
  body: '2'

exports.emptyObject = {}
exports.emptyArray = []
