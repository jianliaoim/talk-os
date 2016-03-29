ease = require './ease'

exports.scrollTo = (node, targetPos, duration = 600, cb) ->
  startPos = node.scrollTop

  if startPos isnt targetPos
    start = null

    animate = (timestamp) ->
      diff = Math.round targetPos - startPos
      start or= timestamp
      progress = timestamp - start
      percent = if progress >= duration then 1 else ease.default progress / duration
      currentPos = startPos + Math.ceil diff * percent

      node.scrollTop = currentPos

      if percent < 1
        window.requestAnimationFrame animate
      else cb?()

    window.requestAnimationFrame animate
