validator = require 'validator'
_ = require 'lodash'
moment = require 'moment-timezone'
app = require '../server'

req = app.request

# Keys will import as request properties
req.importKeys = []

# Keys allowed in `set` function
req.allowedKeys = [
  '_besideId',
  '_creatorId', '_creatorIds',
  '_favoriteIds', '_fromId',
  '_id', '_integrationId',
  '_latestReadMessageId', '_latestRoomId', '_latestTeamId',
  '_maxId', '_markId', '_memberIds', '_messageId', '_messageIds', '_minId',
  '_roomId',
  '_sessionUserId', '_storyId'
  '_tagId', '_tagIds', '_targetId', '_teamId', '_toId', '_toIds',
  '_userId', '_userIds',
  'accessToken', 'accountToken', 'actionName', 'addMembers', 'aggregation', 'appToken', 'arefer', 'attachments', 'atoken', 'apiName', 'avatarUrl',
  'body',
  'callSids', 'category', 'clientId', 'clientSecret', 'clientType', 'codeType', 'color', 'config', 'content', 'customOptions',
  'data', 'description', 'desktopNotification', 'displayMode', 'displayType',
  'email', 'emailNotification', 'emails', 'errorInfo', 'events', 'excludeFields',
  'file', 'fileCategory', 'fileKey', 'fileName', 'fileSize', 'fileType',
  'group', 'guestToken',
  'hasShownRichTextTips', 'hasShownTips', 'hasTag', 'hashId',
  'iconUrl', 'imageHeight', 'imageWidth', 'inviteCode', 'isArchived', 'isDone', 'isDirectMessage', 'isHidden', 'isMute', 'isQuit', 'isGuestEnabled', 'isGuestVisible', 'isPinned', 'isPrivate', 'isPublic',
  'keyword',
  'lang', 'language', 'limit', 'logoUrl',
  'mark', 'maxDate', 'maxUpdatedAt', 'message', 'minDate', 'mobile', 'mobiles', 'msgToken', 'muteWhenWebOnline',
  'name', 'nextUrl', 'nonJoinable', 'notification', 'notifications', 'notifyOnRelated',
  'page', 'password', 'postAt', 'prefs', 'project', 'properties', 'purpose', 'pushOnWorkTime',
  'quote',
  'refer', 'remindAt', 'removeMembers', 'repos', 'role',
  'scope', 'shortName', 'showname', 'signCode', 'socketId', 'sort', 'source', 'sourceId', 'status', 'syncAccount',
  'text', 'timeRange', 'timezone', 'title', 'token', 'topic', 'type',
  'unreadNum', 'url',
  'webData'
]

# Alias keys will be converted to the value key
# e.g. 'user-id' will be set as 'userId' if you set the alias as {'user-id': 'userId'}
# Keys should be lowercase
req.alias =
  'x-socket-id': 'socketId'
  'x-client-type': 'clientType'  # Device type: iOS, Android
  'x-client-id': 'clientId'  # Device uuid
  '_withid': '_toId'
  'q': 'keyword'
  'aid': 'accountToken'
  'x-language': 'lang'
# Validator for each key, value will be dropped if validator returns false
req.validators =
  _general: (val, key) ->
    if key.match /^_.*id$/i  # _ObjectId type
      return if "#{val}".match /[0-9a-f]{24}/ then true else false
    if key.match /Date$/i  # Date type
      val = Number(val) if val.match /^\d{13}$/
      date = new Date(val)
      return if date.getDate() then true else false
    if key.match /url$/i
      return if validator.isURL(val) then true else false
    return true
  limit: (limit) ->
    limit = parseInt(limit)
    return true if 0 < limit < 100
    return false
  email: (email) ->
    email = email.trim()
    return false unless validator.isEmail(email)
    return true
  mobile: (mobile) ->
    /^\+?[0-9]{1}[0-9]{3,14}$/.test mobile
  emails: (emails) ->
    return false unless toString.call(emails) is '[object Array]'
    return emails.every (email) -> validator.isEmail(email)
  role: (role) ->
    return role in ['owner', 'admin', 'member']
  shortName: (shortName) ->
    return true if shortName.match /^[a-z_-]+$/i
    false
  timezone: (timezone) -> if moment().tz(timezone)._z then true else false

# Custom setter for specific key
req.setters =
  _tagIds: (_tagIds) -> _.uniq _tagIds
  limit: (limit) -> Number(limit)
