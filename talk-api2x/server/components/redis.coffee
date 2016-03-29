redis = require 'redis'
Promise = require 'bluebird'
config = require 'config'

Promise.promisifyAll redis.RedisClient.prototype
Promise.promisifyAll redis.Multi.prototype

host = config.redisHost or 'localhost'
port = config.redisPort or 6379

client = redis.createClient(port, host)
client.select(config.redisDb) if config.redisDb

module.exports = client
