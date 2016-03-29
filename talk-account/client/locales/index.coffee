
zhLocales = require './zh'
enLocales = require './en'

exports.get = (key, language) ->
  switch language
    when 'en'
      localeCollection = enLocales
    when 'zh'
      localeCollection = zhLocales
    else
      console.warn "language not passed in at: #{key}"
      localeCollection = zhLocales
  if localeCollection[key]?
    localeCollection[key]
  else
    "__#{key}__"
