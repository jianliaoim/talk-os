assign = require 'object-assign'
recorder = require 'actions-recorder'

if typeof window is 'undefined'
  clientConfig = require '../../config/default'
else
  clientConfig = window._initialStore.client

apiHost = '/account'

controllers = require '../controllers'

if typeof window isnt 'undefined'
  reqwest = require 'reqwest'

ajax = (config) ->
  reqwest assign config,
    headers:
      'X-Language': recorder.getState().getIn [ 'client', 'language' ]

markLoadingBegin = ->
  controllers.setLoading true

markLoadingComplete = ->
  controllers.setLoading false

# requests for mobile

exports.mobileSignUp = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/signup"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.mobileSignIn = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/signin"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.mobileSendVerifyCode = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/sendverifycode"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.mobileSignInByVerifyCode = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/signinbyverifycode"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.mobileResetPassword = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/resetpassword"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.mobileBind = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/bind"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.mobileChange = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/change"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.mobileForceBind = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/forcebind"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.mobileUnbind = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/mobile/unbind"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

# requests based on email

exports.emailSignUp = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/signup"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.emailSignIn = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/signin"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.emailSendVerifyCode = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/sendverifycode"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.emailSignInByVerifyCode = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/signinbyverifycode"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.emailResetPassword = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/resetpassword"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.emailBind = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/bind"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.emailForceBind = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/forcebind"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.emailChange = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/change"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.emailUnbind = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/email/unbind"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

# requests for user

exports.userGet = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/user/get"
    type: 'json'
    method: 'get'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.userAccounts = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/user/accounts"
    type: 'json'
    method: 'get'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

# requests for union

exports.unionBindX = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/union/bind/#{options.refer}"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.unionSiginIn = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/union/signin/#{options.refer}"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.unionForceBindX = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/union/forcebind/#{options.refer}"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

exports.unionUnbindX = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/union/unbind/#{options.refer}"
    type: 'json'
    method: 'post'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

# to be decided
exports.unionCallbackX = (options) ->
  markLoadingBegin()
  ajax
    url: "#{apiHost}/v1/union/callack/#{options.refer}"
    type: 'json'
    method: 'get'
    contentType: 'application/json'
    data: JSON.stringify options.data
    error: options.error
    success: options.success
    complete: markLoadingComplete

# captcha
exports.captchaSetup = (options) ->
  reqwest
    url: "#{clientConfig.captchaService}/setup"
    type: 'json'
    method: 'get'
    contentType: 'application/json'
    data: options.data
    error: options.error
    success: options.success

exports.captchaValid = (options) ->
  reqwest
    url: "#{clientConfig.captchaService}/valid"
    type: 'json'
    method: 'get'
    contentType: 'application/json'
    data: options.data
    error: options.error
    success: options.success

exports.captchaImage = (uid, lang, index) ->
  "#{clientConfig.captchaService}/image?uid=#{uid}&lang=#{lang}&index=#{index}"
