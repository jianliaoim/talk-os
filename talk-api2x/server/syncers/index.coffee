Promise = require 'bluebird'

module.exports =
  teambition: Promise.promisifyAll(require './teambition')
