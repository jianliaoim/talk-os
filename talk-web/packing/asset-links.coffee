
config = require 'config'

if config.env is 'dev'
  assetLinks =
    main: "http://talk.bi:#{config.webpackDevPort}/main.js"
    vendor: "http://talk.bi:#{config.webpackDevPort}/vendor.js"
    style: null
else
  assets = require '../packing/assets'
  cdnPrefix = "#{config.cdn}/talk-web/"

  if config.useCDN
    prefix = cdnPrefix
  else
    prefix = '/'
  assetLinks =
    main: "#{prefix}#{assets.main[0]}"
    style: "#{prefix}#{assets.main[1]}"
    vendor: "#{prefix}#{assets.vendor}"

module.exports = assetLinks
