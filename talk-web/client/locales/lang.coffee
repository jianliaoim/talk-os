
recorder = require 'actions-recorder'

# Todo: language function and Monent locale

enLocale = require '../locales/en'
zhLocale = require '../locales/zh'
zhTwLocale = require '../locales/zh-tw'
moment = require '../util/moment'

if module.hot
  module.hot.accept ['../locales/en', '../locales/zh', '../locales/zh-tw'], ->
    enLocale = require '../locales/en'
    zhLocale = require '../locales/zh'
    zhTwLocale = require '../locales/zh-tw'

cachedLanguage = 'zh'
moment.locale 'zh-cn'

recorder.subscribe (core) ->
  language = exports.getLang()
  if language isnt cachedLanguage
    if language is 'en'
      cachedLanguage = 'en'
      moment.locale 'en'
    else if language is 'zh-tw'
      cachedLanguage = 'zh-tw'
      moment.locale 'zh-tw'
    else if language is 'zh'
      cachedLanguage = 'zh'
      moment.locale 'zh-cn'

exports.getText = (text, language) ->
  language or= exports.getLang()

  if language is 'en'
    localeSource = enLocale
  else if language is 'zh-tw'
    localeSource = zhTwLocale
  else
    localeSource = zhLocale

  if localeSource[text]?
    localeSource[text]
  else
    "{{#{text}}}"

exports.getLang = ->
  store = recorder.getStore()
  language = store.getIn(['prefs', 'language']) or 'zh'
