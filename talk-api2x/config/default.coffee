path = require 'path'

module.exports = config =
  debug: true
  apiHost: 'localhost:7001'
  accountId: 'aid'
  apiVersion: 'v2'
  webHost: 'localhost:7001'
  sessionDomain: '.localhost'
  guestHost: 'localhost:7001'
  schema: 'http'
  mongodb: 'mongodb://localhost:27017/talk'
  redisHost: 'localhost'
  redisPort: 6379
  redisDb: 0
  snapper:
    pub: [6379, 'localhost']
    clientId: 'Client id of snapper'
    clientSecret: 'Client secret of snapper'
    channelPrefix: 'snapper'
    host: 'localhost:7001/snapper'  # For test
  talkAccountApiUrl: 'http://localhost:7001/account'
  talkAccountPageUrl: 'http://localhost:7001/page'
  cdnPrefix: 'https://dn-talk.oss.aliyuncs.com'
  checkToken: 'Check token for heartbeat statement'
  serviceConfig:
    apiHost: 'http://localhost:7001/v2'
    cdnPrefix: "http://localhost:7001/v2/services-static"
    talkAccountApiUrl: 'http://localhost:7001/account'
    teambition:
      clientSecret: 'Your teambition application secret'
      host: 'https://www.teambition.com'
    rss:
      serviceUrl: 'http://127.0.0.1:7411'
    github:
      apiHost: 'https://api.github.com'
    talkai:
      apikey: "Api key of talkai"
      devid: "Devid of talkai"
    trello:
      apiKey: 'Api key of trello'
    serviceTokens:
      weibo: 'Service token of weibo'
      rss: 'Service token of rss'
