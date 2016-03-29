moment = require 'moment'
lang = require '../locales/lang'

startTime = moment()

exports.formatEasy = (someTime) ->
  unless someTime?
    console.error 'time is undefined'
  someTime = moment someTime
  if someTime.isSame startTime, 'day'
    someTime.format 'hh:mm a'
  else if someTime.isSame startTime, 'year'
    someTime.format 'MM-DD HH:mm'
  else
    someTime.format 'YYYY MM-DD'

exports.nowISOString = ->
  (new Date).toISOString()

exports.unix = ->
  (new Date).valueOf()

exports.isHistoryMessage = (messageModel, cacheTime) ->
  messageTime = moment messageModel.get 'createdAt'
  timeFirst = (moment cacheTime.first).add(1, 'second')
  timeLast = (moment cacheTime.last).subtract(1, 'second')

  if messageTime.isBefore timeFirst
    return true
  else if messageTime.isAfter timeLast
    return false
  else
    console.warn 'Message time not decided'
    return false

exports.isBefore = (a, b) ->
  timeA = moment a
  timeB = moment b
  timeA.isBefore timeB

exports.notSameDay = (a, b) ->
  dateA = new Date a
  dateB = new Date b
  return true if dateA.getDate() isnt dateB.getDate()
  return true if dateA.getMonth() isnt dateB.getMonth()
  return true if dateA.getYear() isnt dateB.getYear()
  return false

exports.within1Minute = (a, b) ->
  timeA = new Date a
  timeB = new Date b
  Math.abs(timeA.valueOf() - timeB.valueOf()) <= 60000

exports.formatDayGap = (messageTime) ->
  someMoment = moment messageTime
  format =
    if someMoment.year() is moment().year()
      if moment.locale() is 'en'
        'Do MMMM'
      else
        'MMMM Do'
    else
      if moment.locale() is 'en'
        'Do MMMM YYYY'
      else
        'YYYY MMMM Do'

  return someMoment.format(format)

exports.calendar = (someTime) ->
  someMoment = moment someTime
  nowMoment = moment()
  if someMoment.year() isnt nowMoment.year()
    if(moment.locale() is 'en')
      date = someMoment.format('D/M/YYYY')
    else
      date = someMoment.format('YYYY/M/D')
    return "#{date} #{someMoment.format('LT')}"

  minuteDiff = nowMoment.diff someMoment, 'minute', true
  if minuteDiff < 1
    return lang.getText 'just-now'

  timeText = someMoment.format('LT')
  if someMoment.isSame(nowMoment, 'day')
    return "#{timeText}"

  if(moment.locale() is 'en')
    date = someMoment.format('D/M')
  else
    date = someMoment.format('M/D')
  return "#{date} #{timeText}"

exports.minuteLater = (cb) ->
  setTimeout (-> cb()), (60 * 1000)

exports.formatDate = (someTime) ->
  someMoment = moment someTime
  someMoment.format('LL')

exports.delay = (wait, cb) ->
  setTimeout cb, wait

exports.every = (wait, cb) ->
  setInterval cb, wait

exports.nextTick = (cb) ->
  setTimeout cb, 0

exports.epochISOString = ->
  moment.unix(0).toISOString()

exports.nearlySameSecond = (a, b) ->
  Math.abs(moment(a).diff(b, 'seconds')) < 2

exports.nextMoment = (a) ->
  timeA = moment a
  timeA.add 10, 'ms'
  timeA.toISOString()

exports.createTime = (createTime) ->
  lang
  .getText 'publish-at'
  .replace '{{time}}', exports.calendar createTime

exports.targetTime = (createTime, updateTime) ->
  createTime = new Date createTime
  updateTime = new Date updateTime

  if createTime.getTime() >= updateTime.getTime()
    lang
    .getText 'create-at'
    .replace '{{time}}', exports.calendar createTime
  else
    lang
    .getText 'update-at'
    .replace '{{time}}', exports.calendar updateTime

exports.isMessageEdited = (createTime, updateTime) ->
  ((new Date updateTime).valueOf() - (new Date createTime).valueOf()) > 1000
