LocalStorage = require 'store2'
recorder = require 'actions-recorder'

if typeof window isnt 'undefined'
  cookie = require 'cookie_js'

config = require '../config'
actions = require '../actions'

exports.routeSignIn = ->
  actions.routeSignIn()

exports.routeSignUp = ->
  actions.routeSignUp()

exports.routeForgotPassword = ->
  actions.routeForgotPassword()

exports.signInRedirect = ->
  store = recorder.getStore()
  referer = store.getIn ['client', 'referer']
  siteUrl = store.getIn ['client', 'siteUrl']
  window.location.replace (referer or siteUrl)

exports.updateAccount = (account) ->
  actions.clientAccount account

exports.updatePassword = (password) ->
  actions.clientPassword password

exports.setLoading = (status) ->
  actions.clientLoading status

exports.routeEmailSent = ->
  actions.routeEmailSent()
  exports.storeRefererIntoStorage()

exports.routeSucceedResetting = ->
  actions.routeSucceedResetting()

exports.routeSucceedBinding = ->
  actions.routeSucceedBinding()

exports.routeGo = (info) ->
  actions.routeGo info

exports.resetPassword = ->
  actions.resetPassword()

exports.storeRefererIntoStorage = ->
  store = recorder.getStore()
  referer = store.getIn ['client', 'referer']
  if referer # maybe '' or undefined
    LocalStorage.set 'referer', referer
  else
    LocalStorage.remove 'referer'

exports.takeRefererFromStorage = ->
  referer = LocalStorage.get('referer') or null
  LocalStorage.remove 'referer'
  return referer

exports.redirectThirdPartyAuth = (urlPath) ->
  exports.storeRefererIntoStorage()

  cookieConfigs =
    domain: config.cookieDomain, expires: 7, path: '/'
  cookie.set 'trackingPage', 'login', cookieConfigs
  cookie.set 'trackingPageLabel', "from teambition", cookieConfigs
  cookie.set 'trackingPageTime', window.performance?.timing.navigationStart, cookieConfigs

  location.replace urlPath

exports.redirectBindEmail = ->
  location.replace "#{config.accountUrl}/bind-email?action=bind&next_url=#{encodeURIComponent window.location}"

exports.redirectChangeEmail = ->
  location.replace "#{config.accountUrl}/bind-email?action=change&next_url=#{encodeURIComponent window.location}"

exports.redirectMobileChange = ->
  location.replace "#{config.accountUrl}/bind-mobile?action=change&next_url=#{encodeURIComponent window.location}"

exports.redirectMobileBind = ->
  location.replace "#{config.accountUrl}/bind-mobile?action=bind&next_url=#{encodeURIComponent window.location}"

exports.redirectBind = (refer) ->
  # both "change" and "bind" are using this same API
  location.replace "#{config.accountUrl}/union/#{refer}?next_url=#{encodeURIComponent window.location}&method=bind"

exports.finishUnbind = (refer) ->
  actions.accountUnbind refer

exports.logInRedirectWithData = (account) ->
  cookieConfigs =
    domain: config.cookieDomain, expires: 7, path: '/'
  cookie.set 'trackingPage', 'login', cookieConfigs
  cookie.set 'trackingPageLabel', "from #{account}", cookieConfigs
  cookie.set 'trackingPageTime', window.performance?.timing.navigationStart, cookieConfigs
  exports.signInRedirect()

exports.registerRedirectWithData = (account) ->
  cookieConfigs =
    domain: config.cookieDomain, expires: 7, path: '/'
  cookie.set 'trackingPage', 'register', cookieConfigs
  cookie.set 'trackingPageLabel', "from #{account}", cookieConfigs
  cookie.set 'trackingPageTime', window.performance?.timing.navigationStart, cookieConfigs
  exports.signInRedirect()

exports.loginDirectWithData = ->
  cookieConfigs =
    domain: config.cookieDomain, expires: 7, path: '/'
  cookie.set 'trackingPage', 'direct login', cookieConfigs
  cookie.set 'trackingPageTime', window.performance?.timing.navigationStart, cookieConfigs
  exports.signInRedirect()
