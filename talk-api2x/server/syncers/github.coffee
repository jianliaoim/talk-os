Err = require 'err1st'
Promise = require 'bluebird'
request = require 'request'

class Github

  expire: 86400

  category: 'github'

  getTeamList: (user, tbAlien) ->
    {openId, token} = tbAlien
    options =
      method: 'GET'
      url: "https://api.github.com/users/#{openId}/orgs"
      json: true
      headers:
        Authorization: "token #{token}"
        "User-Agent": "jianliao.com"
    request options
    .spread (res, orgs = []) ->
      orgs = orgs.map? (org) ->
        name: org.login
        sourceId: org.login
      orgs or []

module.exports = new Github
