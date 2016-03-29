{Schema} = require 'mongoose'
Err = require 'err1st'
_ = require 'lodash'
uuid = require 'uuid'
crypto = require 'crypto'
util = require '../util'

_hashId = -> crypto.createHash('sha1').update(uuid.v4() + Date.now()).digest('hex')

module.exports = IntegrationSchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User'
  team: type: Schema.Types.ObjectId, ref: 'Team'
  room: type: Schema.Types.ObjectId, ref: 'Room'
  robot: type: Schema.Types.ObjectId, ref: 'User'
  category: type: String  # Integration category: weibo/github
  hashId: type: String, default: _hashId
  group: type: String
  # For authorized integrations
  token: String
  refreshToken: String
  showname: type: String
  openId: String
  notifications: type: Object
  # Options
  title: type: String
  iconUrl: String
  # Rss
  url: String
  description: type: String
  # Github
  repos: type: Array
  events: Array
  project: _id: String, name: String
  config: Object
  # Data saved by system
  data: Object
  errorInfo: String
  errorTimes: type: Number, default: 0
  lastErrorInfo: String
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
,
  read: 'secondaryPreferred'
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true

IntegrationSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

IntegrationSchema.virtual '_roomId'
  .get -> @room?._id or @room
  .set (_id) -> @room = _id

IntegrationSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

IntegrationSchema.virtual '_robotId'
  .get -> @robot?._id or @robot
  .set (_id) -> @robot = _id

IntegrationSchema.virtual 'webhookUrl'
  .get -> if @hashId then util.buildWebhookUrl(@hashId) else ''
