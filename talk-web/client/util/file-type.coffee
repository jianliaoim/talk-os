FILE_CATEGORY = [ 'text', 'image', 'application', 'audio', 'video' ]

FILE_TYPE =
  text: [ 'txt', 'html', 'css', 'js', 'xml']
  image: [ 'ps', 'ai', 'ae']
  application: [ 'sketch', [ 'ppt', 'pptx' ], [ 'doc', 'docx' ], [ 'xls', 'xlsx' ],
    'pages', 'numbers', 'keynotes', 'pdf', [ 'zip', 'rar', 'dmg', 'jar' ]
  ]
  audio: []
  video: []

findType = (type, arr = []) ->
  pos = -1
  arr.forEach (item, index) ->
    if item instanceof Array
      pos = index if type in item
    else
      pos = index if type is item

  pos

exports.get = (data) ->
  category = data.fileCategory

  x = FILE_CATEGORY.indexOf(category)
  y = findType(data.fileType, FILE_TYPE[category])

  if y < 0
    if category in [ 'image', 'video', 'audio' ]
      y = FILE_TYPE[category].length
    else
      x = FILE_CATEGORY.length
      y = 0

  "#{x * -32}px #{y * -40}px"
