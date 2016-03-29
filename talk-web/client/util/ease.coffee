exports.default = (value) ->
  if value < 0.5
    Math.pow(value * 2, 2) / 2
  else
    1 - Math.pow((1 - value) * 2, 2) / 2
