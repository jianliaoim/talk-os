_ = require 'lodash'
mongoose = require 'mongoose'
Promise = require 'bluebird'
fs = require 'fs'
path = require 'path'
limbo = require 'limbo'
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

accountOptions = {}
accountOptions = auth: authdb: config.mongo.authdb if config.mongo.authdb

if config.mongo.ca
  caFileBuf = fs.readFileSync config.mongo.ca
  certFileBuf = fs.readFileSync config.mongo.cert
  keyFileBuf = fs.readFileSync config.mongo.key
  accountOptions.replset = sslCA: caFileBuf, sslCert: certFileBuf, sslKey: keyFileBuf

account = limbo.use 'account',
  conn: mongoose.createConnection config.mongo.address, accountOptions
  statics: statics
  methods: methods
  overwrites: overwrites
  schemas: schemas
