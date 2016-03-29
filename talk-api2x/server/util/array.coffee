_ = require 'lodash'

module.exports =
  # Pick random elements of array
  arrRandom: (arr, num = 1) ->
    arr = _.clone arr
    _arr = []
    for i in [0...num]
      break unless arr.length
      _arr.push arr.splice(Math.floor(Math.random() * arr.length), 1)[0]
    return _arr
  arrHorizon: (candidates) ->
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
      for i, pinyin of heteronym
        if i is '0'
          _append pinyin
        else
          _expand pinyin

    concatPinyins.map (arr) -> arr.join('').toLowerCase()
