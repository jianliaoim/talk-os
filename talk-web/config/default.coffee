
isGuest = process.env.APP is 'guest'

domain_str = "abc.test.com";

module.exports =
  env: 'static',
  isGuest: isGuest
  version: require('../package.json').version
  apiHost: if isGuest then '/api' else '/v2'
  sockHost: "http://#{domain_str}/snapper",
  inteUrl: 'http://account.project.ci',
  accountUrl: "http://#{domain_str}/account",
  domainUrl: 'http://localhost:8081',
  uploadUrl: 'https://striker.teambition.net',
  cookieDomain: '.localhost'
  pdfStaticHost: 'http://dn-static.oss.aliyuncs.com/pdf-viewer/v0.3.0/index.html',
  loginUrl: "http://#{domain_str}/account",
  logoutUrl: "http://#{domain_str}/account",
  weiboLogin: "http://#{domain_str}/account/union/weibo?method=bind&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/union/weibo/landing'}",
  firimLogin: "http://#{domain_str}/account/union/firim?method=bind&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/union/firim/landing'}",
  githubLogin: "http://#{domain_str}/account/union/github?method=bind&service=talk&nologin=1&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/union/github/landing'}",
  trelloLogin: "http://#{domain_str}/account/union/trello?method=bind&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/union/trello/landing'}",
  teambitionLogin: "http://#{domain_str}/account/union/teambition?method=bind&next_url=#{encodeURIComponent 'http://'+domain_str+'/v2/union/teambtion/landing'}",
  feedbackUrl: "http://#{domain_str}/v2/services/webhook/4d76d92134e727620fce35d7d7c5b1c43921101e"
  windowOnErrorUrl: "http://#{domain_str}/v2/services/webhook/14b30bc73f75044e7500721dee5e985e58049382"
  webpackDevPort: 8081,
  cdn: 'https://dn-st.b0.upaiyun.com'
  isMinified: no
  isProduction: no # whether to add NODE_ENV=production duration packing
  useAnalytics: no
  useCDN: no
  serverEnv: 'dev'
