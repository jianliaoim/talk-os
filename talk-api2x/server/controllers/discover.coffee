app = require '../server'
config = require 'config'
striker = require '../components/striker'
util = require '../util'

limbo = require 'limbo'
{
  TeamModel
} = limbo.use 'talk'

module.exports = discoverController = app.controller 'discover', ->

  @ratelimit '20', only: 'urlMeta'

  @ensure 'url', only: 'urlMeta'

  @action 'index', (req, res, callback) ->

    apis = {}

    for stack in app.routeStack
      apiKey = "#{stack.ctrl}.#{stack.action}".toLowerCase()
      apis[apiKey] or=
        path: stack.path
        method: stack.method

    callback null, apis

  @action 'strikerToken', (req, res, callback) ->
    callback null, token: striker.signAuth()

  @action 'urlMeta', (req, res, callback) ->
    {url} = req.get()
    url = 'http://' + url unless url.indexOf('http') is 0
    util.fetchUrlMetas url
    .timeout 5000
    .nodeify callback

  @action 'toTeam', (req, res, callback) ->
    {shortName} = req.get()
    TeamModel.findOne shortName: shortName, (err, team) ->
      if team?._id
        return res.redirect 302, util.buildTeamUrl(team._id)
      else
        return res.redirect 302, util.buildIndexUrl()
