_ = require 'lodash'
Err = require 'err1st'
Promise = require 'bluebird'
request = require 'request'

limbo = require 'limbo'

{
  TeamModel
  UserModel
} = limbo.use 'talk'

tbAccountUrl = 'https://account.teambition.com'
tbApiUrl = 'https://www.teambition.com/api'

module.exports = teambition =

  getTeams: (union, callback) ->
    options =
      method: 'GET'
      url: tbApiUrl + '/organizations'
      json: true
      headers: Authorization: "OAuth2 #{union.accessToken}"
    request options, (err, res, orgs = []) ->
      return callback(new Err('REQUEST_FAILD')) unless res?.statusCode is 200
      teams = orgs.map (orgz) ->
        return false if not orgz or orgz.isDeleted
        team = name: orgz.name, sourceId: orgz._id
      .filter (team) -> team
      callback err, teams

  getTeam: (sourceId, union, callback) ->
    options =
      method: 'GET'
      url: tbApiUrl + '/organizations/' + sourceId
      json: true
      headers: Authorization: "OAuth2 #{union.accessToken}"

    request options, (err, res, orgz) ->
      return callback(new Err('REQUEST_FAILD')) unless res?.statusCode is 200 and orgz?.name and not orgz.isDeleted
      callback null, name: orgz.name, sourceId: orgz._id

  getTeamMembers: (union, team, callback) ->
    options =
      method: 'GET'
      url: tbApiUrl + "/v2/organizations/#{team.sourceId}/members"
      json: true
      headers: Authorization: "OAuth2 #{union.accessToken}"

    request options, (err, res, tbMembers = []) ->
      return callback(new Err("REQUEST_FAILD")) unless res?.statusCode is 200
      # Reflect teambition rights to talk teams
      members = tbMembers.map (tbMember) ->
        switch Number(tbMember._roleId)
          when 2 then role = 'owner'
          when 1 then role = 'admin'
          else role = 'member'
        userData =
          openId: tbMember._id
          role: role
          mobile: tbMember.phone
          email: tbMember.email
          name: tbMember.name
          avatarUrl: tbMember.avatarUrl
      callback err, members
