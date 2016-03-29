divideText = (text, trigger) ->
  buffer = ''
  pos = 0
  for i in [text.length-1..0]
    pos = i
    if text[i] is trigger
      break
    buffer = text[i] + buffer
  [text.substring(0, pos), buffer]

exports.makeCompleteState = (wholeText, start, special, complete) ->
  textBefore = wholeText[...start]
  textBehind = wholeText[start..]
  [remain, swap] = divideText textBefore, special

  newText = remain + complete + textBehind
  newStart = remain.length + complete.length

  text: newText
  start: newStart
  end: newStart

exports.makeInsertState = (wholeText, start, chunk) ->
  textBefore = wholeText[...start]
  textAfter = wholeText[start..]

  newText = textBefore + chunk + textAfter
  newStart = start + chunk.length

  text: newText
  start: newStart
  end: newStart

exports.getQuery = (text, trigger) ->
  buffer = ''
  for i in [text.length-1..0]
    if text[i] is trigger
      break
    buffer = text[i] + buffer
  buffer

exports.getTrigger = getTrigger = (text, specials) ->
  if not new RegExp(specials.join('|')).test(text)
    null
  else
    special = null
    for i in [text.length-1..0]
      if text[i] is ' '
        break
      if text[i] in specials
        special = text[i]
        break
    special
