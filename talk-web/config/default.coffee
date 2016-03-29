
isGuest = process.env.APP is 'guest'

module.exports =
  env: 'static'
  isMinified: no
  isProduction: no
  useCDN: no
  serverEnv: 'dev'
  useAnalytics: no

  isGuest: isGuest
  version: require('../package.json').version
  apiHost: if isGuest then '/api' else '/v2'
  sockHost: 'http://localhost:7001/snapper',
  inteUrl: 'https://account.teambition.com',
  accountUrl: 'http://localhost:7001/account',
  domainUrl: 'http://localhost:7001:8081',
  uploadUrl: 'http://localhost:7001/striker',
  cookieDomain: '.localhost'
  pdfStaticHost: 'http://dn-static.oss.aliyuncs.com/pdf-viewer/v0.3.0/index.html',
  loginUrl: 'http://localhost:7001/account/login',
  logoutUrl: 'http://localhost:7001/account/logout',
  weiboLogin: "http://localhost:7001/account/union/weibo?method=bind&next_url=#{encodeURIComponent 'http://localhost:7001/v2/union/weibo/landing'}",
  firimLogin: "http://localhost:7001/account/union/firim?method=bind&next_url=#{encodeURIComponent 'http://localhost:7001/v2/union/firim/landing'}",
  githubLogin: "http://localhost:7001/account/union/github?method=bind&service=talk&nologin=1&next_url=#{encodeURIComponent 'http://localhost:7001/v2/union/github/landing'}",
  trelloLogin: "http://localhost:7001/account/union/trello?method=bind&next_url=#{encodeURIComponent 'http://localhost:7001/v2/union/trello/landing'}",
  teambitionLogin: "http://localhost:7001/account/union/teambition?method=bind&next_url=#{encodeURIComponent 'http://localhost:7001/v2/union/teambtion/landing'}",
  feedbackUrl: 'http://localhost:7001/v2/services/webhook/4d76d92134e727620fce35d7d7c5b1c43921101e'
  windowOnErrorUrl: 'http://localhost:7001/v2/services/webhook/14b30bc73f75044e7500721dee5e985e58049382'
  webpackDevPort: 8081
