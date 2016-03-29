should = require 'should'
Promise = require 'bluebird'
limbo = require 'limbo'

app = require '../app'
util = require '../../server/util'

{prepare, cleanup} = app

{
  UsageModel
  UsageHistoryModel
} = limbo.use 'talk'

saveCallUsageJob = require '../../server/jobs/save-call-usage'

describe 'Job#SaveCallUsage', ->

  before prepare

  it 'should save usage of phone call', (done) ->
    $saveCallUsage = saveCallUsageJob app.team1._id, [
      '16031610490641240001030600108079'
      '1603161049064124000103060010807a'
    ]

    $checkUsage = $saveCallUsage.then ->
      UsageModel.findOneAsync
        type: 'call'
        team: app.team1._id
        month: util.getCurrentMonth()

    .then (usage) ->
      usage.amount.should.eql 25

    $checkUsageHistory = $saveCallUsage.then ->
      UsageHistoryModel.findAsync
        type: 'call'
        team: app.team1._id

    .then (usageHistories) ->
      usageHistories.length.should.eql 2
      usageHistories.forEach (usageHistory) ->
        usageHistory.data.should.have.properties 'callSid'

    Promise.all [$checkUsage, $checkUsageHistory]
    .nodeify done

  after cleanup
