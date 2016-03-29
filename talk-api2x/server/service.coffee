_ = require 'lodash'
path = require 'path'
Promise = require 'bluebird'
config = require 'config'
Err = require 'err1st'
requireDir = require 'require-dir'
serviceLoader = require 'talk-services'
limbo = require 'limbo'
{
  UserModel
} = limbo.use 'talk'

serviceLoader.config = config.serviceConfig

serviceNames = [
  'incoming', 'outgoing', 'robot', 'teambition', 'rss', 'trello', 'cloudinsight', 'github', 'firim', 'jobtong', 'pingxx',
  'gitlab', 'coding', 'gitcafe', 'bitbucket', 'jinshuju', 'jiankongbao', 'kf5', 'swathub',
  'csdn', 'oschina', 'buildkite', 'codeship', 'jira', 'qingcloud', 'mikecrm', 'bughd',
  'travis', 'jenkins', 'circleci', 'magnumci', 'newrelic', 'heroku', 'goldxitudaily', 'mailgun',
  'weibo',
  # Hidden services
  'talkai', 'email'
]

_initRobot = (service) ->
  conditions = service: service.name, isRobot: true

  keyMapping =
    name: 'title'
    avatarUrl: 'iconUrl'

  $robot = UserModel.findOneAsync conditions

  .then (robot) ->
    if robot
      isntModified = Object.keys(keyMapping).every (key) -> robot[key] is service[keyMapping[key]]
      return robot if isntModified

    else
      robot = new UserModel conditions
      robot[key] = service[valKey] for key, valKey of keyMapping

    update = robot.toJSON()
    update.updatedAt = new Date
    delete update._id
    delete update.id

    options = upsert: true, new: true

    UserModel.findOneAndUpdateAsync conditions, update, options

  .then (robot) ->
    robot = robot[0] if toString.call(robot) is '[object Array]'
    throw new Error("Service #{service.name} load robot failed") unless robot
    service.robot = robot

  return $robot

# Initialize all the services
Promise.map serviceNames, (serviceName) ->
  serviceLoader.load serviceName, _initRobot

_tokenToService = _.invert(config.serviceConfig.serviceTokens)

if config.debug
  express = require 'express'
  app = require './server'
  app.use "/#{config.apiVersion}/services-static/", express.static(path.join(__dirname, '../node_modules/talk-services'))

serviceLoader.getServiceByToken = (token) ->
  name = _tokenToService[token]
  return Promise.reject(new Err('INVALID_SERVICE')) unless name
  serviceLoader.load name

serviceLoader.getRobotOf = (name) ->
  serviceLoader.load(name).then (service) -> service.robot

serviceLoader.settings = ->
  unless serviceLoader.$settings
    serviceLoader.$settings = Promise.map serviceNames, (serviceName) -> serviceLoader.load serviceName
    .filter (service) -> not service.isHidden
    .map (service) -> service.toJSON()
  serviceLoader.$settings

module.exports = serviceLoader
