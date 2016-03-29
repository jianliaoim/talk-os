Promise = require 'bluebird'
Err = require 'err1st'
limbo = require 'limbo'
logger = require 'graceful-logger'
util = require '../util'

{
  UsageModel
  UsageHistoryModel
} = limbo.use 'talk'

module.exports = (_teamId, callSids, delayedTimes = 0) ->

  {schedule} = require '../components'

  pendingCallSids = []

  Promise.map callSids, (callSid) ->

    $callTime = util.getCallResultAsync callSid

    .then (callResult) ->
      # Not finished or failed
      if callResult?.state is '2'
        logger.warn "This callSid has failed", callSid
        return

      if callResult?.state isnt '1'
        pendingCallSids.push callSid
        return

      unless !isNaN(Number(callResult?.callTime)) and Number(callResult?.callTime) >= 0
        throw new Err('INVALID_OBJECT', 'callResult')
      callTime = Number(callResult.callTime)

    $saveCallTime = $callTime.then (callTime) ->
      return unless callTime
      usageHistory = new UsageHistoryModel
        amount: callTime
        type: 'call'
        team: _teamId
        data: callSid: callSid

      $usageHistory = usageHistory.$save()

      $incrUsage = UsageModel.incrAsync _teamId, 'call', callTime

      Promise.all [$incrUsage, $usageHistory]

    $saveCallTime

  .then ->
    if pendingCallSids.length
      delayedTimes += 1
      if delayedTimes > 6  # 60 minutes later
        return logger.warn "This session delayed too many times, callSids: ", pendingCallSids

      schedule.addTask
        action: 'saveCallUsage'
        executeAt: Date.now() + 600000
        args: [_teamId, pendingCallSids, delayedTimes]
      .catch (err) -> logger.warn err.stack
