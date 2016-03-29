express = require 'express'
_ = require 'lodash'
multer  = require 'multer'

module.exports = app = express()

# for fetching image url content testing
fileData =
  fileKey: '1107c714fa14c8b34aa01f82612a0141fc90'
  fileName: 'thumbnail.png'
  fileType: 'png'
  fileSize: 1031231
  fileCategory: 'image'
  imageWidth: 1920
  imageHeight: 1080

app.use multer(rename: (fieldname, filename) -> filename)

app.get '/thumbnail.png', (req, res) ->
 options =
    root: __dirname + '/public/image/'
    headers:
      'Content-Type': 'image/png'

  res.sendFile 'thumbnail.png', options

app.post '/forremote', (req, res) ->
  res.status(200).json fileData

app.post '/upload', (req, res) ->
  if req.files?.file
    res.status(200).json
      fileKey: '1107c714fa14c8b34aa01f82612a0141fc90'
      fileName: req.files?.file.originalname
      fileType: req.files?.file.extension
      fileSize: req.files?.file.size
  else
    res.statu(400).json message: "Invalid file"
