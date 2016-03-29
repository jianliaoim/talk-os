exports.image = (imageHeight, imageWidth, min, max) ->
  if imageWidth > max
    if imageHeight < min
      height = min
      width = max
    else if (imageHeight / imageWidth) > 1
      height = max
      width = imageWidth / (imageHeight / max)
    else
      height = imageHeight / (imageWidth / max)
      width = max
  else if imageHeight > max
    if imageWidth < min
      height = max
      width = min
    else if (imageWidth / imageHeight) > 1
      height = imageHeight / (imageWidth / max)
      width = max
    else
      height = max
      width = imageWidth / (imageWidth / max)

  height = Math.round height or imageHeight
  width = Math.round width or imageWidth

  { height, width }

exports.thumbnail = (thumbnailUrl, height, width) ->
  if thumbnailUrl?.length and height? and width?
    thumbnailUrl
    .replace(/(\/h\/\d+)/g, "/h/#{ height }")
    .replace(/(\/w\/\d+)/g, "/w/#{ width }")
  else null
