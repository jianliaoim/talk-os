# Intialize the components and connection of database
Promise = require 'bluebird'

components =
  apn: require './apn'
  i18n: require './i18n'
  logger: require './logger'
  mailgun: require './mailgun'
  pusher: require './pusher'
  redis: require './redis'
  socket: require './socket'
  schedule: require './schedule'
  striker: require './striker'
  lexer: require './lexer'

module.exports = components

components.limbo = require './limbo'
