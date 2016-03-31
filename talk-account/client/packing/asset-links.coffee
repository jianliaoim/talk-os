
config = require 'config'

assets = require '../packing/assets'
prefix = '/account/build/'
assetLinks =
  main: "#{prefix}#{assets.main[0]}"
  style: "#{prefix}#{assets.main[1]}"
  vendor: "#{prefix}#{assets.vendor}"

module.exports = assetLinks
