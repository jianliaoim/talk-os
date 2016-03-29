list = require './emojis-list'
type = require './type'

TEST_REGEX = /\:([a-z0-9_+-]+)(?:\[((?:[^\]]|\][^:])*\]?)\])?\:/g
emoticons =
  '+1': 'thumbsup'
  '-1': 'thumbsdown'

list = list.map (emoji) ->
  ":#{emoji}:"

exports.toElement = (name) ->
  name = emoticons[name] or name
  "<img align=\"absmiddle\" class=\"emoji\" src=\"https://dn-talk.oss.aliyuncs.com/icons/emoji/#{name}.png\">"

module.exports.replace = (text) ->
  return text if not type.isString(text)
  text.replace TEST_REGEX, (match, name) ->
    if list.indexOf(match) is -1
      match
    else
      exports.toElement(name)
