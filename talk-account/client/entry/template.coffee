
fs = require 'fs'
path = require 'path'
stir = require 'stir-template'
React = require 'react'
config = require 'config'
ReactDOM = require 'react-dom/server'

locales = require '../locales'
assetLinks = require '../packing/asset-links'

{html, head, title, meta, link, script, body, div} = stir

Page = React.createFactory require '../app/page'

baidu = fs.readFileSync (path.join __dirname, 'baidu.html'), 'utf8'
mixpanel = fs.readFileSync (path.join __dirname, 'mixpanel.html'), 'utf8'
googleAnalytics = fs.readFileSync (path.join __dirname, 'google-analytics.html'), 'utf8'

exports.render = (core) ->
  store = core.get('store')
  storeJSON = "window._initialStore = (#{JSON.stringify(store)})"
  language = store.getIn ['client', 'language']

  stir.render stir.doctype(),
    html null,
      head null,
        title null, locales.get('jianliao', language)
        meta charset: 'utf-8'
        meta 'http-equiv': 'X-UA-Compatible', content: 'IE=edge, chrome=1'
        meta name: 'referrer', content: 'origin-when-cross-origin'
        meta name: 'superfish', content: 'nofish'
        meta name: 'viewport', content: 'initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no'
        link rel: 'icon', href: 'https://jianliao.com/favicon.ico'
        if assetLinks.style?
          link rel: 'stylesheet', href: assetLinks.style
        googleAnalytics if config.useAnalytics
        mixpanel if config.useAnalytics
        baidu if config.useAnalytics
        script null, storeJSON
        script src: assetLinks.vendor, defer: true
        script src: assetLinks.main, defer: true
      body null,
        div id: 'app',
          ReactDOM.renderToString Page(core: core)
