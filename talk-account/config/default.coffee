countries = require './util/countries'

domain_str = "wx.hoootools.com";

module.exports =
  env: 'static'
  debug: true
  cdn: '/account'
  isMinified: no
  webpackDevPort: 8011
  useCDN: no
  checkToken: 'Check token for heartbeat'
  resourceDomain: "http://#{domain_str}/account"
  useAnalytics: no
  # URL
  accountUrl: "http://#{domain_str}/account"
  siteUrl: "http://#{domain_str}"
  weiboLogin: "http://#{domain_str}/account/union/weibo?method=bind&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/weibo/landing'}",
  firimLogin: "http://#{domain_str}/account/union/firim?method=bind&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/firim/landing'}",
  githubLogin: "http://#{domain_str}/account/union/github?method=bind&service=talk&nologin=1&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/github/landing'}",
  trelloLogin: "http://#{domain_str}/account/union/trello?method=bind&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/trello/landing'}",
  teambitionLogin: "http://#{domain_str}/account/union/teambition?method=bind&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/teambtion/landing'}",
  # Cookies
  cookieDomain: '.localhost'
  accountCookieId: 'aid'
  accountCookieSecret: 'Cookie secret of account'
  accountCookieExpires: 2592000
  # Connections
  mongo:
    address: 'mongodb://localhost:27017/talk_account'
  redis:
    host: '10.10.10.1'
  # Client
  client:
    countries: countries
