
if typeof window isnt 'undefined'
  module.exports = window._initialStore.config or {}
else
  module.exports = {}
