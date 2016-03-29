_ = require 'lodash'
mongoose = require 'mongoose'
Promise = require 'bluebird'
fs = require 'fs'
path = require 'path'
limbo = require 'limbo'
logger = require './logger'
config = require 'config'
{schemas, statics, methods, overwrites} = require '../schemas'

# Promisify mongoose objects
Promise.promisifyAll mongoose.Model
Promise.promisifyAll mongoose.Query.base

_.values(schemas).forEach (schema) ->
  Promise.promisifyAll schema.statics
  Promise.promisifyAll schema.methods

Promise.promisifyAll statics
Promise.promisifyAll methods

## Connect to mongodb

talkOptions = {}
talkOptions = auth: authdb: config.mongoAuthDb if config.mongoAuthDb

if config.mongoCA
  caFileBuf = fs.readFileSync config.mongoCA
  certFileBuf = fs.readFileSync config.mongoCert
  keyFileBuf = fs.readFileSync config.mongoKey
  talkOptions.replset = sslCA: caFileBuf, sslCert: certFileBuf, sslKey: keyFileBuf

talk = limbo.use 'talk',
  conn: mongoose.createConnection config.mongodb, talkOptions
  statics: statics
  methods: methods
  overwrites: overwrites
  schemas: schemas

module.exports = limbo
