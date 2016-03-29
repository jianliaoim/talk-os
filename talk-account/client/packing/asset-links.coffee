
config = require 'config'

if config.env is 'dev'
  assetLinks =
    main: "http://#{config.resourceDomain}:#{config.webpackDevPort}/main.js"
    vendor: "http://#{config.resourceDomain}:#{config.webpackDevPort}/vendor.js"
    style: null
else
  assets = require '../packing/assets'
  cdnPrefix = "#{config.cdn}/"

  if config.useCDN
    prefix = cdnPrefix
  else
    prefix = '/build/'
  assetLinks =
    main: "#{prefix}#{assets.main[0]}"
    style: "#{prefix}#{assets.main[1]}"
    vendor: "#{prefix}#{assets.vendor}"

module.exports = assetLinks
