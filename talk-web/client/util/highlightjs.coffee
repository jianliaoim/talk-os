hljs = require 'highlight.js/lib/highlight'
Immutable = require 'immutable'

assets = Immutable.fromJS [
  { key: 'clojure', path: require 'highlight.js/lib/languages/clojure' }
  { key: 'coffeescript', path: require 'highlight.js/lib/languages/coffeescript' }
  { key: 'cpp', path: require 'highlight.js/lib/languages/cpp' }
  { key: 'cs', path: require 'highlight.js/lib/languages/cs' }
  { key: 'css', path: require 'highlight.js/lib/languages/css' }
  { key: 'go', path: require 'highlight.js/lib/languages/go' }
  { key: 'haskell', path: require 'highlight.js/lib/languages/haskell' }
  { key: 'html', path: require 'highlight.js/lib/languages/xml' }
  { key: 'java', path: require 'highlight.js/lib/languages/java' }
  { key: 'javascript', path: require 'highlight.js/lib/languages/javascript' }
  { key: 'json', path: require 'highlight.js/lib/languages/json' }
  { key: 'lisp', path: require 'highlight.js/lib/languages/lisp' }
  { key: 'markdown', path: require 'highlight.js/lib/languages/markdown' }
  { key: 'objectivec', path: require 'highlight.js/lib/languages/objectivec' }
  { key: 'php', path: require 'highlight.js/lib/languages/php' }
  { key: 'python', path: require 'highlight.js/lib/languages/python' }
  { key: 'ruby', path: require 'highlight.js/lib/languages/ruby' }
  { key: 'sql', path: require 'highlight.js/lib/languages/sql' }
]

assets.forEach (value) ->
  hljs.registerLanguage value.get('key'), value.get('path')
