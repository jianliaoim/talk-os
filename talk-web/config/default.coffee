
isGuest = process.env.APP is 'guest'

module.exports =
  env: 'dev',
  isGuest: isGuest
  version: require('../package.json').version
  apiHost: if isGuest then '/api' else '/v2'
  sockHost: 'http://snapper.dev.talk.ai',
  inteUrl: 'http://account.project.ci',
  accountUrl: 'http://account.talk.bi',
  domainUrl: 'http://talk.bi:8081',
  uploadUrl: 'https://striker.teambition.net',
  cookieDomain: '.talk.bi'
  pdfStaticHost: 'http://dn-static.oss.aliyuncs.com/pdf-viewer/v0.3.0/index.html',
  loginUrl: 'http://account.talk.bi',
  logoutUrl: 'http://talk.bi/site',
  weiboLogin: "http://account.talk.bi/union/weibo?method=bind&next_url=#{encodeURIComponent 'http://talk.bi/v2/union/weibo/landing'}",
  firimLogin: "http://account.talk.bi/union/firim?method=bind&next_url=#{encodeURIComponent 'http://talk.bi/v2/union/firim/landing'}",
  githubLogin: "http://account.talk.bi/union/github?method=bind&service=talk&nologin=1&next_url=#{encodeURIComponent 'http://talk.bi/v2/union/github/landing'}",
  trelloLogin: "http://account.talk.bi/union/trello?method=bind&next_url=#{encodeURIComponent 'http://talk.bi/v2/union/trello/landing'}",
  teambitionLogin: "http://account.talk.bi/union/teambition?method=bind&next_url=#{encodeURIComponent 'http://talk.bi/v2/union/teambtion/landing'}",
  feedbackUrl: 'http://talk.bi/v2/services/webhook/4d76d92134e727620fce35d7d7c5b1c43921101e'
  windowOnErrorUrl: 'http://talk.bi/v2/services/webhook/14b30bc73f75044e7500721dee5e985e58049382'
  webpackDevPort: 8081,
  cdn: 'https://dn-st.b0.upaiyun.com'
  isMinified: no
  isProduction: no # whether to add NODE_ENV=production duration packing
  useAnalytics: no
  useCDN: no
  serverEnv: 'dev'
