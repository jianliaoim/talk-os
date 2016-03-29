moment = require 'moment'
request = require 'request'
config = require 'config'
Promise = require 'bluebird'

requestAsync = Promise.promisify request

startDate = moment("2014-05-01")
endDate = moment('2016-03-01')

searchHost = "#{config.searchProtocol}://#{config.searchHost}:#{config.searchPort}"

buildRange = ->
  query:
    range:
      createdAt:
        gte: startDate.startOf('month').format('YYYY-MM-DD')
        lte: startDate.endOf('month').format('YYYY-MM-DD')

checkCount = ->

  month = startDate.startOf('month').format('YYYYMM')

  $monthlyIndexCount = Promise.resolve().then ->
    options =
      method: 'POST'
      url: "#{searchHost}/talk_messages_#{month}/_count"
      json: true
    requestAsync(options).spread (res) -> res?.body?.count or 0

  $rangeIndexCount = Promise.resolve().then ->
    options =
      method: 'POST'
      url: "#{searchHost}/talk_messages_v2/_count"
      json: true
      body: buildRange()
    requestAsync(options).spread (res) -> res?.body?.count or 0

  Promise.all [$monthlyIndexCount, $rangeIndexCount]

  .spread (monthlyIndexCount, rangeIndexCount) ->
    console.log "Month #{month} Indexed #{monthlyIndexCount} Total #{rangeIndexCount}"
    if monthlyIndexCount is rangeIndexCount
      return true
    else return false

  .then (synced) -> Promise.delay(5000).then(checkCount) unless synced

reindex = ->
  month = startDate.startOf('month').format('YYYYMM')

  reindexUrl =

  options =
    method: 'POST'
    url: "#{searchHost}/talk_messages_v2/_reindex/talk_messages_#{month}"
    json: true
    body: buildRange()

  console.log JSON.stringify(options, null, 2)

  requestAsync(options).then(checkCount)

main = ->
  if startDate > endDate
    console.log 'All reindex scheduled', new Date
    process.exit()

  reindex().then -> startDate.add 1, 'month'

  .delay 1000

  .then -> main()

  .catch (err) ->
    console.warn err.stack
    process.exit 1

console.log 'Reindex start', new Date
main()
