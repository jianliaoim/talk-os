_ = require 'lodash'

apiConfig = require '../talk-api2x/config/default'
accountConfig = require '../talk-account/config/default'
snapperConfig = require '../talk-snapper/config/default'

module.exports = _.assign snapperConfig, accountConfig, apiConfig
