replaceMap =
  code: 'span'
  pre: 'div'
  table: 'div'
  blockquote: 'div'
  tr: 'span'
  td: 'span'
  b: 'span'
  tt: 'span'
  h1: 'div'
  h2: 'div'
  h3: 'div'
  h4: 'div'
  h5: 'div'
  h6: 'div'
  p: 'div'
  a: 'span'
  ol: 'div'
  ul: 'div'
  li: 'div'

copyChildren = (source, target) ->
  if source.children.length > 0
    source.children.forEach (el, index) ->
      if el?
        target.appendChild el
  else if source.innerHTML.length > 0
    target.innerHTML = source.innerHTML

# http://blog.gospodarets.com/native_smooth_scrolling/
exports.smoothScrollTo = (node, x, y) ->
  # http://blog.gospodarets.com/native_smooth_scrolling/
  # https://developer.mozilla.org/en-US/docs/Web/CSS/scroll-behavior
  isSmoothScrollSupported = document.body.style.scrollBehavior?

  if isSmoothScrollSupported
    node.scrollTo
      'behavior': 'smooth'
      'left': x
      'top': y
  else if node.scrollTo?
    # only window object uses scrollTo
    node.scrollTo x, y
  else
    node.scrollLeft = x
    node.scrollTop = y

exports.isNodeInRoot = (node, root) ->
  while node
    if node is root
      return true
    node = node.parentNode
  return false

exports.isElementInViewport = (el, port) ->
  return false if not el or not port
  elBounds = el.getBoundingClientRect()
  portBounds = port.getBoundingClientRect()
  elBounds.top <= portBounds.bottom and elBounds.bottom >= portBounds.top
