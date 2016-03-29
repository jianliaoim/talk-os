Immutable = require 'immutable'

exports.assets = Immutable.OrderedMap
  'txt': Immutable.Map { name: 'Plain Text', codemirror: 'null', highlightjs: 'nohighlight' }
  'clojure': Immutable.Map { name: 'Clojure', codemirror: 'clojure', highlightjs: 'clojure' }
  'coffee': Immutable.Map { name: 'CoffeeScript', codemirror: 'coffeescript', highlightjs: 'coffeescript' }
  'cpp': Immutable.Map { name: 'C/C++', codemirror: 'clike', highlightjs: 'cpp' }
  'cs': Immutable.Map { name: 'C#', codemirror: 'clike', highlightjs: 'cs' }
  'css': Immutable.Map { name: 'CSS', codemirror: 'css', highlightjs: 'css' }
  'go': Immutable.Map { name: 'Go', codemirror: 'go', highlightjs: 'go' }
  'hs': Immutable.Map { name: 'Haskell', codemirror: 'haskell', highlightjs: 'haskell' }
  'html': Immutable.Map { name: 'HTML', codemirror: 'htmlmixed', highlightjs: 'html' }
  'java': Immutable.Map { name: 'Java', codemirror: 'clike', highlightjs: 'java' }
  'js': Immutable.Map { name: 'JavaScript', codemirror: 'javascript', highlightjs: 'javascript' }
  'json': Immutable.Map { name: 'JSON', codemirror: 'javascript', highlightjs: 'json' }
  'lisp': Immutable.Map { name: 'Lisp', codemirror: 'commonlisp', highlightjs: 'lisp' }
  'md': Immutable.Map { name: 'Markdown', codemirror: 'markdown', highlightjs: 'markdown' }
  'objc': Immutable.Map { name: 'Objective-C', codemirror: 'clike', highlightjs: 'objectivec' }
  'php': Immutable.Map { name: 'PHP', codemirror: 'php', highlightjs: 'php' }
  'py': Immutable.Map { name: 'Python', codemirror: 'python', highlightjs: 'python' }
  'rb': Immutable.Map { name: 'Ruby', codemirror: 'ruby', highlightjs: 'ruby' }
  'sql': Immutable.Map { name: 'SQL', codemirror: 'sql', highlightjs: 'sql' }

exports.getAssets = ->
  exports.assets

exports.getAssetsByKey = (key) ->
  exports.assets.get(key) or exports.assets.get('txt')

exports.getCodemirror = (key) ->
  exports.getAssetsByKey key
  .get 'codemirror'

exports.getHighlightJS = (key) ->
  exports.getAssetsByKey key
  .get 'highlightjs'

exports.getName = (key) ->
  exports.getAssetsByKey key
  .get 'name'
