Err = require 'err1st'
Promise = require 'bluebird'
requestAsync = Promise.promisify(require 'request')
config = require 'config'
moment = require 'moment'

module.exports =
  sendSMS: (mobile, text, options = {}, callback = ->) ->
    # @osv
    return callback(null, ok: 1)
    {redis} = require '../components'
    endOfToday = moment().endOf('day').valueOf()
    rateKey = "sms:#{mobile}:#{endOfToday}"

    if options.dailyRate
      $overRate = redis.getAsync rateKey

      .then (rateNum) ->
        return unless rateNum
        if Number(rateNum) > options.dailyRate
          throw new Err 'MOBILE_RATE_EXCEEDED'
        return

    else $overRate = Promise.resolve()

    $sendSMS = $overRate.then ->
      _options =
        method: 'POST'
        url: config.sms.host + '/send'
        json: true
        body:
          key: config.sms.key
          secret: config.sms.secret
          phone: mobile
          ip: options.ip
          _userId: options._userId
          refer: options.refer
          msg: text
          uid: options.uid or options._userId
      requestAsync _options
      .spread (res) ->
        throw new Err('SEND_SMS_ERROR') unless res?.statusCode is 200
        res.body

    $setRate = $sendSMS.then ->
      remainSeconds = Math.floor((endOfToday - Date.now())/1000)
      redis
        .multi()
        .incr rateKey
        .expire rateKey, remainSeconds
        .execAsync()

    Promise.all [$sendSMS, $setRate]
    .spread (body) -> body
    .nodeify callback
