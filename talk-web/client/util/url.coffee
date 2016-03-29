detect = require './detect'

exports.issueUrl = 'http://tburl.in/3e8ad2b0'
exports.feedbackUrl = 'https://jianliao.com/page/invite/e840f0402t'
exports.xiaoaiAvatar = 'https://dn-talk.oss.aliyuncs.com/images/icons/talkai@2x.png'
exports.emailIcon = 'https://dn-talk.oss.aliyuncs.com/icons/email@2x.png'

exports.iosAppUrl = 'https://itunes.apple.com/cn/app/talk-by-teambition/id922425179?mt=8'
exports.macAppUrl = 'https://dn-talk.oss.aliyuncs.com/app-downloads/talk.dmg'
exports.androidAppUrl  = 'https://dn-talk.oss.aliyuncs.com/downloads/talk-teambition-release.apk'
exports.windows32AppUrl = 'https://dn-talk.oss.aliyuncs.com/app-downloads/talk-win32-ia32.zip'
exports.windows64AppUrl = 'https://dn-talk.oss.aliyuncs.com/app-downloads/talk-win32-x64.zip'
exports.linux32AppUrl = 'https://dn-talk.oss.aliyuncs.com/app-downloads/talk-linux-ia32.tar.gz'
exports.linux64AppUrl = 'https://dn-talk.oss.aliyuncs.com/app-downloads/talk-linux-x64.tar.gz'

jianliaoPages = [
  /^\/site/
  /^\/blog/
  /^\/doc/
  /^\/page/
  /^\/v\d/
  /^\/t\//
]

exports.isInRoutes = (locationOrigin, href) ->
  isOrigin = href.indexOf(locationOrigin) is 0

  routePath = href.substr(locationOrigin.length)
  isException = jianliaoPages.some (route) ->
    routePath.match(route)?

  isOrigin and not isException
