lexer = require 'talk-lexer'

lexer.stringify = (message) ->
  return message unless toString.call(message) is '[object String]'
  message.replace /\<\$(.*?)\$\>/g, (m, $1) ->
    [cmd, data, text] = $1.split '|'
    text

lexer.parse = (message) ->
  return message unless toString.call(message) is '[object String]'
  matches = message.match /\<\$(.*?)\$\>/g
  return [] unless matches
  matches.map (match) ->
    match = match[2...-2]
    _matches = match.split '|'
    [cmd, data] = _matches
    cmd: cmd
    data: data
    text: _matches[2..]?.join '|'

module.exports = lexer
