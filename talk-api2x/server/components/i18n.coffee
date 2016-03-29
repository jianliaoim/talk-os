i18n = require 'i18n'
requireDir = require 'require-dir'
innerLocales = requireDir "#{__dirname}/../config/locales"

pattern = /\{\{__([\s\S]+?)\}\}/g

i18n.configure
  directory: "#{__dirname}/../../locales"
  defaultLocale: 'zh'
  locales: ['zh', 'en']
  cookie: 'lang'
  updateFiles: false

# Grep pharses and replace with the messages in the dictionary
i18n.replace = (str) ->
  return str unless toString.call(str) is '[object String]'
  str.replace pattern, (m, code) -> i18n.__(code) or code

# Generate i18n data by inner locale configurations
i18n.fns = (lang) -> innerLocales[lang] or innerLocales['zh']

module.exports = i18n
