path = require 'path'
crypto = require 'crypto'
moment = require 'moment'
iconv = require 'iconv-lite'
_ = require 'lodash'
fs = require 'fs'
qs = require 'querystring'
zlib = require 'zlib'
he = require 'he'
urlLib = require 'url'
validator = require 'validator'
stream = require 'stream'
logger = require 'graceful-logger'

Promise = require 'bluebird'
request = require 'request'
requestAsync = Promise.promisify request
async = require 'async'
charsetLib = require 'charset'
jschardet = require 'jschardet'
htmlparser = require 'htmlparser2'
{Parser} = htmlparser
Err = require 'err1st'

striker = require '../components/striker'

config = require 'config'

module.exports = requestUtil =

  ###*
   * Get random user agent
   * @return {String}
  ###
  getUserAgent: ->
    userAgents = [
      'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36'
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36'
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36'
      'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36'
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1'
      'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0'
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10; rv:33.0) Gecko/20100101 Firefox/33.0'
      'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0'
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20130401 Firefox/31.0'
      'Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0'
    ]
    _.sample userAgents

  maybeDecompress: (res, encoding) ->
    if /\bdeflate\b/.test encoding
      decompress = zlib.createInflate()
    else if /\bgzip\b/.test encoding
      decompress = zlib.createGunzip()
    if decompress then res.pipe(decompress) else res

  maybeTranslate: (res, charset) ->
    decoder = new stream.Transform
    decoder._transform = (chunk, encoding, callback) ->
      if /utf-*8/i.test(charset)
        callback null, chunk
      else
        charset or= charsetLib res.headers, chunk
        charset or= jschardet.detect(chunk).encoding?.toLowerCase() or 'utf-8'
        try
          chunk = iconv.decode chunk, charset
        catch err
        callback null, chunk
    res.pipe(decoder)

  ###*
   * Get complete url from options
   * @param  {String} uri - Origin url
   * @param  {Object} options - Options parsed by url.parse
   * @return {String} url
  ###
  completeRelativeUrl: (uri, options) ->
    return uri if validator.isURL uri
    return uri if uri.match /^data\:/
    return options.protocol + uri if uri.indexOf('//') is 0
    uriObj = urlLib.parse(uri)
    for key, val of uriObj
      options[key] = val if val
    urlLib.format options

  fetchUrlMetas: (url) ->
    res = null
    url = 'http://' + url unless url.indexOf('http') is 0
    contentType = ''

    options =
      url: url
      method: 'GET'
      encoding: null
      headers: 'User-Agent': 'jianliao.com'
      timeout: 10 * 1000

    # Read meta infomation
    $meta = new Promise (resolve, reject) ->
      req = request options
      req.on 'response', (res) ->

        return resolve() unless res?.statusCode >= 200 and res?.statusCode < 300
        charset = charsetLib res.headers
        encoding = res.headers['content-encoding'] || 'identity'
        contentType = res.headers['content-type'].split('/').shift() if res.headers['content-type']

        res = requestUtil.maybeDecompress res, encoding
        res = requestUtil.maybeTranslate res, charset
        resolve res

      req.on 'error', reject

    .then (res) ->

      return unless res

      new Promise (resolve, reject) ->
        meta = {}
        openTitle = false

        parser = new Parser
          onopentag: (name, attribs) ->
            if name is 'link' and attribs.rel is 'shortcut icon' and attribs.href
              meta.faviconUrl = requestUtil.completeRelativeUrl(attribs.href, urlLib.parse(url))
            if name is 'link' and attribs.rel?.indexOf('icon') > -1 and attribs.href
              meta.faviconUrl or= requestUtil.completeRelativeUrl(attribs.href, urlLib.parse(url))
            # The Open Graph protocol http://ogp.me/
            if name is 'meta' and attribs.property is 'og:title' and attribs.content?.length
              meta.title = he.decode attribs.content or ''
            if name is 'meta' and attribs.property is 'og:description' and attribs.content?.length
              meta.text = he.decode attribs.content or ''
            if name is 'meta' and attribs.property is 'og:image' and attribs.content?.length
              meta.imageUrl = attribs.content

            if name is 'meta' and attribs.name is 'description' and attribs.content?.length and not meta.text
              meta.text = he.decode attribs.content or ''
            if name is 'meta' and attribs.name is 'title' and attribs.content?.length and not meta.title
              meta.title = he.decode attribs.content or ''
            if name is 'title' then openTitle = true
          ontext: (text) ->
            if openTitle then meta.title or= he.decode text or ''
          onclosetag: (tagname) ->
            if tagname is 'title' then openTitle = false

        res.on 'data', (data) -> parser.write data

        res.on 'error', reject

        res.on 'end', ->
          meta.title = meta.title?.trim() or ''
          meta.contentType = contentType
          resolve meta
          parser.end()

    .then (meta = {}) -> meta

    # Read favicon infomation
    $setFaviconUrl = $meta.then (meta) ->

      return if meta.faviconUrl

      requestUtil.getFaviconUrl url

      .then (faviconUrl) ->
        meta.faviconUrl = faviconUrl if faviconUrl

      .catch (err) -> logger.warn err.stack

    Promise.all [$meta, $setFaviconUrl]
    .spread (meta) -> meta

  getFaviconUrl: (url) ->
    urlUtil = require './url'
    faviconUrl = urlUtil.getBaseUrl(url) + '/favicon.ico'

    $faviconUrl = requestAsync
      method: 'HEAD'
      headers: 'User-Agent': 'jianliao.com'
      url: faviconUrl
    .spread (res, body) ->
      return unless res?.statusCode >= 200 and res?.statusCode < 300
      if /image/.test res.headers['content-type']
        return faviconUrl

  proxyRequest: (req, {method, url, json}, callback = ->) ->
    return callback(new Err('PARAMS_MISSING', url)) unless url

    method or= 'get'
    method = method.toLowerCase()
    stream = request[method] url

    stream.on 'response', (res) ->

      body = ''
      res.on 'data', (data) -> body += data
      res.on 'end', (err) ->
        if json
          try
            body = JSON.parse body
          catch e
            body = {}
            err = e
        callback err, body

    req.pipe stream

  saveToFileServer: (files, callback) ->

    _saveToFileServer = (file) ->

      token = striker.signAuth()

      url = config.strikerHost + '/upload'

      throw new Err('FILE_MISSING') unless file.path

      formData = file: fs.createReadStream file.path

      requestAsync
        method: 'POST'
        url: url
        formData: formData
        headers: Authorization: token
        json: true
      .spread (res, file) ->
        throw new Err('FILE_SAVE_FAILED') unless file?.fileKey
        file

    if toString.call(files) is '[object Array]'
      $file = Promise.resolve files
      .map _saveToFileServer
    else
      $file = Promise.resolve files
      .then _saveToFileServer

    $file.nodeify callback

  fetchAndSaveRemoteImg: (sourceUrl, callback) ->
    token = striker.signAuth()

    destUrl = config.strikerHost + '/forremote'

    $file = requestAsync
      method: 'POST'
      url: destUrl
      timeout: 10 * 1000
      form:
        downloadUrl: sourceUrl
        source: 'remote'
      headers: Authorization: token
      json: true
    .spread (res, file) ->
      throw new Err('FILE_SAVE_FAILED') unless file?.fileKey
      file

    $file.nodeify callback

  getAccountUser: (accountToken, callback) ->
    return callback(new Err('PARAMS_MISSING', 'accountToken')) unless accountToken
    options =
      url: config.talkAccountApiUrl + '/v1/user/get'
      json: true
      qs: accountToken: accountToken
    console.log options
    request options, (err, res, user) ->
      return callback(new Err('TOKEN_EXPIRED')) unless user?._id
      callback err, user

  getCallResult: (callSid, callback) ->
    return callback() unless config.voipAccount
    timestamp = moment().format('YYYYMMDDHHmmss')
    {accountSid, accountToken, appId, apiUrl} = config.voipAccount
    sig = crypto.createHash('md5').update("#{accountSid}#{accountToken}#{timestamp}").digest('hex').toUpperCase()
    options =
      url: "#{apiUrl}/Accounts/#{accountSid}/CallResult"
      json: true
      method: 'GET'
      headers:
        Authorization: new Buffer("#{accountSid}:#{timestamp}").toString('base64')
        "User-Agent": requestUtil.getUserAgent()
      qs:
        sig: sig
        callsid: callSid
    request options, (err, res) ->
      unless res?.statusCode is 200 and res.body?.CallResult
        return callback(new Err('VOIP_REQUEST_FAILD', res?.body?.statusMsg))
      callback err, res.body.CallResult

Promise.promisifyAll requestUtil
