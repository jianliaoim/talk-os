countries = require './util/countries'

module.exports =
  env: 'static'
  debug: true
  cdn: '/account'
  isMinified: no
  webpackDevPort: 8011
  useCDN: no
  checkToken: 'Check token for heartbeat'
  resourceDomain: 'http://localhost:7001/account'
  useAnalytics: no
  # URL
  accountUrl: 'http://localhost:7001/account'
  siteUrl: 'http://localhost:7001'
  weiboLogin: "http://localhost:7001/account/union/weibo?method=bind&next_url=#{encodeURIComponent 'http://localhost:7001/v2/weibo/landing'}",
  firimLogin: "http://localhost:7001/account/union/firim?method=bind&next_url=#{encodeURIComponent 'http://localhost:7001/v2/firim/landing'}",
  githubLogin: "http://localhost:7001/account/union/github?method=bind&service=talk&nologin=1&next_url=#{encodeURIComponent 'http://localhost:7001/v2/github/landing'}",
  trelloLogin: "http://localhost:7001/account/union/trello?method=bind&next_url=#{encodeURIComponent 'http://localhost:7001/v2/trello/landing'}",
  teambitionLogin: "http://localhost:7001/account/union/teambition?method=bind&next_url=#{encodeURIComponent 'http://localhost:7001/v2/teambtion/landing'}",
  # Cookies
  cookieDomain: '.localhost'
  accountCookieId: 'aid'
  accountCookieSecret: 'Cookie secret of account'
  accountCookieExpires: 2592000
  # Connections
  mongo:
    address: 'mongodb://localhost:27017/talk_account'
  redis:
    host: 'localhost'
  # Client
  client:
    countries: countries
