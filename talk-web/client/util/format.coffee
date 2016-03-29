xss = require 'xss'

if typeof window isnt 'undefined'
  FileAPI = require 'fileapi'

trimLeft = (text) ->
  return text if text.length is 0
  return text if text[0] isnt ' '
  trimLeft text[1..]

exports.markLink = (content) ->
  content
  .replace /(http(s)?:\/\/[\d\w\/\.\%\&\?\=\-\#\:\+\@]+)/g,
    '<a href="$1" target="_blank">$1</a>'

exports.maskEmail = (email) ->
  email.replace(/(\w)([^@]*)(\w)@/, '$1**$3@')

exports.escape100 = (number) ->
  switch
    when number > 100 then '99+'
    when number is 0 then ''
    else "#{number}"

exports.htmlAsText = (html) ->
  # https://github.com/leizongmin/js-xss/blob/master/example/strip_tag.js
  xss html,
    whiteList: []
    stripIgnoreTag: true
    stripIgnoreTagBody: ['script']

exports.textAsAbbr = (str) ->
  length = str.trim().length
  str = if length > 140 then "#{str.substr 0, 140}..." else str
  return str

exports.trimLeft = trimLeft

exports.fileName = (text, length) ->
  if text.length < length
    return text
  pieces = text.split('.')
  if pieces.length is 2
    basename = pieces[0]
    extension = pieces[1]
  else
    basename = pieces[...-1].join('.')
    extension = pieces[pieces.length - 1]
  prefix = basename.substr 0, length - (extension.length + 4 + 3 + 1)
  suffix = basename.substr -4
  "#{prefix}...#{suffix}.#{extension}"

exports.mockFileInfo = (file) ->
  fileCategory = file.type.split('/')[0]
  fileInfo =
    downloadUrl: null
    fileCategory: fileCategory
    fileKey: null
    fileName: file.name
    fileSize: file.size
    fileState: undefined
    fileType: file.type
    imageWidth: null
    imageHeight: null
    source: 'local'
    thumbnailUrl: null
  return fileInfo
