express = require 'express'
_ = require 'lodash'

module.exports = app = express()

tbOrgs =
  '55f7d19c85efe377996a113f':
    _id: "55f7d19c85efe377996a113f"
    name: "orgz1"
  '55f7d19c85efe377996a114f':
    _id: "55f7d19c85efe377996a114f"
    name: "orgz2"

tbMembers =
  "55f7d19c85efe377996a113f": [
    _id: '55f7d19c85efe377996a1230'
    _roleId: 2
    phone: '13011111111'
    email: '13011111111@teambition.com'
    name: '13011111111'
  ,
    _id: '55f7d19c85efe377996a1231'
    _roleId: 0
    phone: '13011111112'
    email: '13011111112@teambition.com'
    name: '13011111111'
  ],
  "55f7d19c85efe377996a114f": [
    _id: '55f7d19c85efe377996a1231'
    _roleId: 0
    phone: '13011111112'
    email: '13011111112@teambition.com'
    name: '13011111111'
  ]

app.get '/tbapi/organizations', (req, res) ->
  res.status(200).json _.values(tbOrgs)

app.get '/tbapi/organizations/:_id', (req, res) ->
  res.status(200).json tbOrgs[req.params._id]

app.get '/tbapi/v2/organizations/:_id/members', (req, res) ->
  res.status(200).json tbMembers[req.params._id]

app.get '/url/content', (req, res) ->
  res.set 'Content-Type', 'text/html'
  res.status(200).send '<title> jianliao</title>'
