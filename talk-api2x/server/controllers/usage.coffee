_ = require 'lodash'
Err = require 'err1st'
Promise = require 'bluebird'
limbo = require 'limbo'
logger = require 'graceful-logger'

app = require '../server'
util = require '../util'
{schedule} = require '../components'

{
  UsageModel
  UsageHistoryModel
} = limbo.use 'talk'

usageDefaultPlan =
  userMessage: maxAmount: -1
  inteMessage: maxAmount: 10000
  file: maxAmount: 1048576000  # 1 GB
  call: maxAmount: 6000  # 6000 Seconds

module.exports = usageController = app.controller 'usage', ->

  @mixin require './mixins/permission'

  @ensure 'callSids', only: 'call'
  @before 'isTeamMember', only: 'read call'

  @action 'read', (req, res, callback) ->
    {_teamId} = req.get()
    month = util.getCurrentMonth()

    $usages = Promise.map Object.keys(usageDefaultPlan), (type) ->

      conditions =
        team: _teamId
        type: type
        month: month

      UsageModel.findOneAsync conditions

      .then (usage) ->

        return usage if usage
        update = maxAmount: usageDefaultPlan[type].maxAmount
        options = upsert: true, new: true
        UsageModel.findOneAndUpdateAsync conditions, update, options

    $usages.nodeify callback

  @action 'call', (req, res, callback) ->
    {callSids} = req.get()

    unless toString.call(callSids) is '[object Array]' and callSids.length
      return callback(new Err('PARAMS_INVALID', 'callSids'))

    schedule.addTask
      action: 'saveCallUsage'
      executeAt: Date.now() + 600000
      args: [req.get('_teamId'), req.get('callSids')]
    .catch (err) -> logger.warn err.stack

    callback null, ok: 1
