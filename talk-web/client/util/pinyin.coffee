Immutable = require 'immutable'
pinyin = require 'pinyin'

# from talk-api2x server/util/array.coffee
arrHorizon = (candidates) ->
  concatPinyins = []
  _append = (word) ->
    return concatPinyins = [[word]] unless concatPinyins.length
    pinyins.push(word) for pinyins in concatPinyins

  _expand = (word) ->
    cloneConcatPinyins = []
    return concatPinyins = [[word]] unless concatPinyins.length
    cloneConcatPinyins.push pinyins.slice(0, pinyins.length - 1).concat(word) for pinyins in concatPinyins
    concatPinyins = concatPinyins.concat(cloneConcatPinyins)

  for heteronym in candidates
    for i, word of heteronym
      if i is '0'
        _append word
      else
        _expand word

  concatPinyins.map (arr) -> arr.join('').toLowerCase()

exports.make = (word) ->
  return unless word
  pinyins = arrHorizon(pinyin(word, heteronym: true, style: pinyin.STYLE_NORMAL))
  pys = arrHorizon(pinyin(word, heteronym: true, style: pinyin.STYLE_FIRST_LETTER))

  Immutable.fromJS
    pinyin: pinyins[0]
    pinyins: pinyins
    py: pys[0]
    pys: pys
