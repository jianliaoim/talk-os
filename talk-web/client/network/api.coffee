# API module
# 用法请参照测试代码：test/network/api.spec.coffee

Immutable = require 'immutable'

reqwest = require '../util/reqwest'

urls = require './urls'
notifyActions = require '../actions/notify'
lang = require '../locales/lang'
time = require '../util/time'

config = require '../config'

getSocketId = ->
  config['X-Socket-Id']

reqwestErrorHandler = (err) ->
  return if config.isGuest

  resp =
    try
      JSON.parse(err.response)
    catch
      {}

  if err.status is 400
    notifyActions.warn resp.message
  else if err.status is 403
    # code 201: NOT LOGIN
    # code 220: TOKEN EXPIRED
    if resp.code is 201 or resp.code is 220
      # 首次登录没有socket id, 不需要提示然后等3秒
      firstTimeLogin = not getSocketId()?
      if not firstTimeLogin
        notifyActions.error lang.getText('force-logout')
      delay = if firstTimeLogin then 0 else 3000
      time.delay delay, ->
        window.location.replace config.accountUrl


prepareAjaxMethod = (url, method) ->
  (options) ->
    # convert to immutable object
    options = Immutable.fromJS(options) or Immutable.Map()

    # throw error if GET request is receiving data
    if (method is 'get') and options.has('data')
      throw new Error("#{url} is a GET request, it should not get any data.")

    # construct new url with pathParams
    pathParams = url
      .split /\//
      .filter (param) ->
        param[0] is ':'
      .map (pathParam) ->
        pathParam.slice(1)

    newUrl = pathParams.reduce (url, pathParam) ->
      paramValue = options.getIn ['pathParams', pathParam]
      if paramValue?
        url.replace(":#{pathParam}", paramValue)
      else
        throw new Error("#{url} has invalid path params.")
    , url

    # construct new url with queryParams
    if options.has('queryParams')
      notEmpty = not options.get('queryParams').isEmpty()
      allValid = options.get('queryParams').every (queryParam) -> queryParam?
      if notEmpty and allValid
        urlPart = options.get('queryParams')
          .map (value, key) ->
            "#{key}=#{value}"
          .join '&'
        newUrl = "#{newUrl}?#{urlPart}"
      else
        throw new Error("#{url} has invalid query params. #{options.get('queryParams')}")

    # remove property
    options = options.delete('pathParams').delete('queryParams')

    # prepare request data
    if options.has('data')
      options = options.set('data', JSON.stringify(options.get('data')))

    # add reqwest optionsurations
    options = options.merge
      url: config.apiHost + newUrl
      method: method.toUpperCase()
      contentType: 'application/json'
      headers:
        'X-Socket-Id': getSocketId()
        'X-Language': lang.getLang()
      error: reqwestErrorHandler

    reqwest(options.toJS())

constructUrl = (stringOrObject, method) ->
  if Immutable.Map.isMap(stringOrObject)
    stringOrObject.map (value) ->
      constructUrl value, method
  else
    url = Immutable.Map().set(method, prepareAjaxMethod(stringOrObject, method))

api = Immutable.fromJS urls
  .map constructUrl
  .reduce (prev, next) ->
    prev.mergeDeep next
  .toJS()

api.get = (url) ->
  options =
    url: url
    method: 'GET'
    headers:
      'X-Language': lang.getLang()
      'X-Socket-Id': getSocketId()
  reqwest(options)

api.post = (url, data) ->
  options =
    url: url
    method: 'POST'
    data: data
    headers:
      'X-Language': lang.getLang()
      'X-Socket-Id': getSocketId()
  reqwest(options)

module.exports = api
