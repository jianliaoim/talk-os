path = require 'path'

domain_str = "wx.hoootools.com";

module.exports = config =
  debug: true
  apiHost: domain_str
  accountId: 'aid'
  apiVersion: 'v2'
  webHost: domain_str
  sessionDomain: '.localhost'
  guestHost: domain_str
  schema: 'http'
  mongodb: 'mongodb://localhost:27017/talk'
  redisHost: '10.10.10.1'
  redisPort: 6379
  redisDb: 0
  snapper:
    pub: [6379, '10.10.10.1']
    clientId: 'Client id of snapper'
    clientSecret: 'Client secret of snapper'
    channelPrefix: 'snapper'
    host: "#{domain_str}/snapper"  # For test
  talkAccountApiUrl: "http://#{domain_str}/account"
  talkAccountPageUrl: "http://#{domain_str}/page"
  cdnPrefix: 'https://dn-talk.oss.aliyuncs.com'
  checkToken: 'Check token for heartbeat statement'
  serviceConfig:
    apiHost: "http://#{domain_str}/v2"
    cdnPrefix: "http://#{domain_str}/v2/services-static"
    talkAccountApiUrl: "http://#{domain_str}/account"
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
