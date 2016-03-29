redis = require 'redis'
config = require 'config'
Promise = require 'bluebird'

client = redis.createClient(config.redis.port or 6379, config.redis.host or '127.0.0.1')
client.select config.redis.db if config.redis.db

Promise.promisifyAll client

module.exports = client
