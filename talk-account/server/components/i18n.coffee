i18n = require 'i18n'

i18n.configure
  locales: ['zh', 'en']
  defaultLocale: 'zh'
  cookie: 'lang'
  directory: "#{__dirname}/../../client/locales"
  updateFiles: false

module.exports = i18n
