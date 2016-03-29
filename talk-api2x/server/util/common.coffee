uuid = require 'uuid'

module.exports = commonUtil =
  getIdByDate: (date, postfix = '0000000000000000') ->
    date = date.toDate() if date.toDate?
    date = new Date(date) unless toString.call(date) is '[object Date]'
    head = Math.floor(date.getTime() / 1000).toString('16')
    head + postfix
  genInviteCode: ->
    uuid.v1().split('-')[0] + (Math.random()*10**18).toString(36)[...2]  # length 10 string
  getCurrentMonth: ->
    date = new Date
    new Date date.getFullYear(), date.getMonth()
