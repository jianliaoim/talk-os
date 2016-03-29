Immutable = require 'immutable'

typeUtil = require './type'

lang = require '../locales/lang'
config = require '../config'

# https://github.com/chriso/validator.js
# coffeelint: disable=max_line_length
EmailRegExp = /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/

MobileRegExp = /^(\+?0?86\-?)?1[345789]\d{9}$/

UrlRegExp = /^(?:\w+:)?(\/\/)?([^\s\.]+\.\S{2}|localhost[\:?\d]*)\S*$/

exports.getDay = (date) ->
  date or= new Date()
  return new Date(date.getFullYear(), date.getMonth(), date.getDate())

exports.getDateByTimeZone = (date, timeZone) ->
  return date unless date
  date = new Date(date)
  hours = date.getHours()
  date.setHours(hours + timeZone)
  return date

exports.maybeEmail = (str) ->
  if typeUtil.isString(str) and str.indexOf('@') isnt -1 then true else false

exports.isEmail = (str) ->
  EmailRegExp.test(str)

exports.isId = (str) ->
  if typeUtil.isString(str) and /^[a-zA-Z0-9]{24}$/.test(str) then true else false

exports.isEmpty = (obj) ->
  if obj
    for key of obj
      return not Object::hasOwnProperty.call(obj, key)
  return true

exports.lengthOf = (str) ->
  len = 0
  if typeUtil.isString(str)
    rest = str.replace(/[\u4e00-\u9fa5]/g, ->
      len += 2
      return ''
    )
    len += rest.length
  len

exports.cutString = (str, len, suffix) ->
  return '' unless typeUtil.isString(str)
  if @lengthOf(str) <= len
    return str
  else
    index = 0
    count = 0
    result = ''
    while count < len
      chr = str.charAt(index)
      if /[\u4e00-\u9fa5]/.test(chr)
        count += 2
      else
        count++
      result += chr
      index++
    result = result + suffix
  return result

exports.parseJSON = (str) ->
  try
    return JSON.parse(str)
  catch error
    console?.error(error)
  return null

exports.parseUA = ->
  if typeof window is 'undefined'
    return os: 'linux', browser: 'nodejs'

  pf = window.navigator.platform.toLowerCase()
  ua = window.navigator.userAgent.toLowerCase()
  platforms = [
    /(windows) [\d.]+/, /(linux)/, /(mac)intel|(mac)intosh|(mac)_powerpc/
  ]
  browsers = [
    /ms(ie) [\d.]+/, /(firefox)\/[\d.]+/, /(chrome)\/[\d.]+/, /(opera).[\d.]+/, /version\/[\d.]+.*(safari)/
  ]
  # 探测操作系统
  os = ''
  platforms.forEach (x) ->
    s = pf.match(x)
    if s
      os = s[1]
  # 探测浏览器
  browser = ''
  browsers.forEach (x) ->
    s = ua.match(x)
    if s
      browser = s[1]
  return { os, browser }

exports.charCount = (str) ->
  sum = 0
  for i in [0..str.length]
    ch = str.charCodeAt(i)
    if ch > 0 and ch < 255
      sum += 0.5
    else
      sum += 1
  Math.round sum - 1

exports.isMobile = (str) ->
  MobileRegExp.test(str)

exports.combineMessages = (messages) ->
  reducer = (reduction, value) ->
    previous = reduction.last()
    if previous.get('body') is value.get('body') and previous.get('isSystem') and value.get('isSystem')
      newPrevious = previous
      if not previous.has('creators')
        newPrevious = previous.set('creators', Immutable.List([previous.get('creator')]))
      newPrevious = newPrevious
        .delete 'creator'
        .update 'creators', (creators) ->
          creatorId = value.getIn(['creator', '_id'])
          if creatorId? and creatorId isnt creators.last().get('_id')
            creators.push value.get('creator')
          else
            creators
      reduction.butLast().push newPrevious
    else
      reduction.push value

  messages.rest().reduce reducer, messages.take(1)

exports.imageRotateScale = (iWidth, iHeight, cWidth, cHeight) ->
  # iWidth, iHeight 是图片旋转前的数据, 原图大小， 不是在container里缩放过的
  # 这个函数的测试全是用真图对过的，都是对的。

  scale = 1

  if iHeight > iWidth
    scale = cWidth / cHeight

    if cWidth > iHeight and iHeight > cHeight
      scale = iHeight / cHeight

    if cWidth / cHeight > iHeight/ iWidth
      scale = iHeight / iWidth

    if cWidth / cHeight < iWidth / iHeight
      scale = iWidth / iHeight
  else
    scale = cHeight / cWidth

    if cHeight > iWidth and iWidth > cWidth
      scale = iWidth / cWidth

    if cHeight / cWidth > iWidth / iHeight
      scale = iWidth / iHeight

    if cHeight / cWidth < iHeight / iWidth
      scale = iHeight / iWidth

  # 原图宽高都比container小
  if iHeight < cHeight and iWidth < cWidth and iHeight < cWidth and iWidth < cHeight
    scale = 1

  scale

exports.isUrl = (str) ->
  UrlRegExp.test str

exports.formatObject = (ob, arr) ->
  resultObject = {}

  for key, value of ob
    if typeof value isnt 'undefined' and (not arr? or (key in arr))
      resultObject[key] = value

  resultObject

exports.withMachineInfo = (text, store) ->
  name = store.getIn ['user', 'name']
  email = store.getIn ['user', 'email']
  mobile = store.getIn ['user', 'mobile']
  userId = store.getIn ['user', '_id']
  text or= ''
  text += '\n\n'
  text += "Version: #{config.version}\n"
  text += "Platform: #{window.navigator.platform}\n"
  text += "UserAgent: #{window.navigator.userAgent}\n"
  text += '\n'
  text += "UserId: #{userId}\n"
  text += "Name: #{name}\n" if name
  text += "Email: #{email}\n" if email
  text += "Mobile: #{mobile}\n" if mobile
  text += '\n'
  text += "Router: #{JSON.stringify(store.get('router'), null, 2)}\n"
  text += "Until now: #{Math.round(window.performance.now() / 1000)}s" if window.performance
  text
