path = require 'path'
_ = require 'lodash'
qs = require 'querystring'
urlLib = require 'url'
config = require 'config'

module.exports = urlUtil =

  buildIndexUrl: -> "#{config.schema}://#{config.webHost}"

  buildApiUrl: -> "#{config.schema}://#{config.apiHost}/#{config.apiVersion}"

  buildAccountPageUrl: -> config.talkAccountPageUrl

  buildPageUrl: -> "#{config.schema}://#{config.webHost}/page"

  buildInviteUrl: (inviteCode) -> urlUtil.buildPageUrl() + "/invite/#{inviteCode}"

  buildTeamUrl: (_teamId, _roomId, _chatId) ->
    url = "#{config.schema}://#{config.webHost}/team/#{_teamId}"
    if _roomId?
      url += "/room/#{_roomId}"
    else if _chatId?
      url += "/chat/#{_chatId}"
    return url

  buildStoryUrl: (_teamId, _storyId) ->
    url = "#{config.schema}://#{config.webHost}/team/#{_teamId}/story/#{_storyId}"

  buildShortTeamUrl: (shortName) ->
    url = if shortName then "#{config.schema}://#{config.webHost}/t/#{shortName}" else undefined

  buildCamoUrl: (url) ->
    # @osv
    return url
    return url unless url
    url = url.trim()
    # Do not use camo url when url protocal is https
    return url if url.indexOf('http') isnt 0 or url.indexOf('https') is 0
    strikerUrl = config.strikerHost
    # Do not build camo url twice
    return url if url.indexOf(strikerUrl) > -1
    _crypto = require './crypto'
    return strikerUrl + "/camo/" + _crypto.encrypt url, config.camoSecret

  buildGuestUrl: (guestToken) ->
    return guestToken unless guestToken
    return "#{config.schema}://#{config.guestHost}/rooms/#{guestToken}"

  buildWebhookUrl: (hashId) ->
    return urlUtil.buildApiUrl() + "/services/webhook/#{hashId}"

  buildTbOrgzUrl: (_orgzId) -> "#{config.tbHost}/organization/#{_orgzId}/projects"

  randomAvatarUrl: -> "https://dn-st.qbox.me/user_default_avatars/#{Math.floor(Math.random() * 20 + 1)}.png"

  getBaseUrl: (url) ->
    urlOptions = urlLib.parse url
    "#{urlOptions.protocol or 'http:'}//#{urlOptions.host}"

  attachFromUrl: (url) ->
    return url unless url
    return url if url.indexOf('utm_source=jianliao.com') > -1
    if url.indexOf('?') is -1
      url += '?utm_source=jianliao.com'
    else
      url += '&utm_source=jianliao.com'
    url

  buildAppMsgUrl: (url, params = {}) ->
    return url unless url
    if url.indexOf('?') is -1
      url += "?#{qs.stringify(params)}"
    else
      url += "&#{qs.stringify(params)}"
