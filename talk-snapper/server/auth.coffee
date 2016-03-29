crypto = require 'crypto'
logger = require 'graceful-logger'

rateMap = {}

limitation =
  60: 60
  300: 200
  600: 300

cleanupTimer = setInterval ->
  now = Date.now()
  for timeKey, val of rateMap
    [rate, startTime] = timeKey.split '_'
    if ((now / 1000 / rate) - Number(startTime)) > 1
      delete rateMap[timeKey]
, 60000

module.exports = (req, done) ->

  rateKey = crypto.createHash('md5').update("#{req.forwarded?.ip}.#{req.headers?['user-agent']}").digest('hex')
  isExceeded = false
  for rate, limit of limitation
    timeKey = "#{rate}_" + Math.floor(Date.now() / 1000 / rate)
    rateMap[timeKey] or= {}
    rateMap[timeKey][rateKey] or= 0
    rateMap[timeKey][rateKey] += 1
    isExceeded = true if rateMap[timeKey][rateKey] > limit

  if isExceeded
    logger.info "Rate limit exceeded on ip #{req.forwarded?.ip}, ua #{req.headers?['user-agent']}"
    return done new Error('Rate limit exceeded')

  done()
