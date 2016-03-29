
if typeof window is 'undefined'
  module.exports = require '../config/default'
else
  module.exports = window._initialStore.config
