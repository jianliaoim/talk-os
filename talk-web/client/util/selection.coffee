
lazyModules = require './lazy-modules'

exports.insertText = (anchorNode, anchorOffset, text) ->
  rangy = lazyModules.load('rangy')
  r = rangy.createRange()
  r.setStart anchorNode, anchorOffset
  textNode = document.createElement 'span'
  textNode.innerHTML = text.replace(/\s/g, '&nbsp;')
  r.insertNode textNode
  r.setStartAfter textNode
  sel = rangy.getSelection()
  sel.removeAllRanges()
  sel.addRange r
  sel.collapseToEnd()

exports.moveForwardSpaceAfter = (startEl) ->
  rangy = lazyModules.load('rangy')
  space = document.createElement 'span'
  space.innerHTML = '&nbsp;'
  if startEl.nextSibling?
    startEl.parentElement.insertBefore space, startEl.nextSibling
  else
    startEl.parentElement.appendChild space
  r = rangy.createRange()
  sel = rangy.getSelection()
  r.selectNode space
  sel.removeAllRanges()
  sel.addRange r
  sel.collapseToEnd()

exports.getEmojiNode = (emoji) ->
  img = document.createElement 'img'
  img.setAttribute 'role', 'emoji'
  img.src = "https://dn-talk.oss.aliyuncs.com/icons/emoji/#{emoji}.png"
  return img

exports.getImageNode = (src) ->
  img = document.createElement 'img'
  img.src = src
  return img

# get start selection, go back by 1 letter, replace whole range
exports.completeText = (startSel, endSel, el) ->
  rangy = lazyModules.load('rangy')
  r = rangy.createRange()
  r.setStart startSel.node, (startSel.offset - 1)
  r.setEnd endSel.node, endSel.offset
  r.deleteContents()
  r.insertNode el
  sel = rangy.getSelection()
  sel.removeAllRanges()
  r2 = rangy.createRange()
  r2.setStartAfter el
  r2.collapse()
  sel.addRange r2

# explained at:
# https://gist.github.com/jiyinyiyong/f79c2bdf3fa646042173
exports.getCaretTopPoint = (node, offset) ->
  if offset > 0
    r2 = document.createRange()
    r2.setStart node, (Math.min (offset - 1), node.textContent.length)
    # use Math.min to bypass a bug in Talk Web
    r2.setEnd node, (Math.min offset, node.textContent.length)
    # https://developer.mozilla.org/en-US/docs/Web/API/range.getBoundingClientRect
    # IE9, Safari?(but look good in Safari 8)
    rect = r2.getBoundingClientRect()
    return x: rect.right, y: rect.top, y2: rect.bottom
  else if offset < node.length # textNode has length
    r2 = document.createRange()
    r2.setStart node, offset
    r2.setEnd node, (offset + 1)
    rect = r2.getBoundingClientRect()
    return x: rect.left, y: rect.top, y2: rect.bottom
  else
    # https://developer.mozilla.org/en-US/docs/Web/API/Element.getBoundingClientRect
    rect = node.getBoundingClientRect()
    styles = window.getComputedStyle node
    lineHeight = parseInt styles.lineHeight
    fontSize = parseInt styles.fontSize
    # roughly half the whitespace... but not exactly
    delta = (lineHeight - fontSize) / 2
    return x: rect.left, y: (rect.top + delta)

exports.setEndOfContenteditable = (contentEditableElement) ->
  rangy = lazyModules.load('rangy')
  r = rangy.createRange()
  r.selectNodeContents contentEditableElement
  sel = rangy.getSelection()
  sel.setSingleRange r
  sel.collapseToEnd()
