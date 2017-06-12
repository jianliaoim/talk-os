_ = require 'lodash'

apiConfig = require '../talk-api2x/config/default'
accountConfig = require '../talk-account/config/default'
snapperConfig = require '../talk-snapper/config/default'

searchHost: 'localhost'
searchPort: 9200
searchProtocol: 'http'

module.exports = _.assign snapperConfig, accountConfig, apiConfig
