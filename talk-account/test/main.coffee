requireDir = require 'require-dir'

app = require '../server/server'
unionserver = require './unionserver'

requireDir './apis', recurse: true
requireDir './client', recurse: true
requireDir './utils', recurse: true
