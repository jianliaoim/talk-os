pinyin = require 'pinyin'
uuid = require 'uuid'
config = require 'config'

module.exports =

  randomEmail: (name) ->
    email = pinyin(name, style: pinyin.STYLE_NORMAL).join('').replace /[^a-z0-9]+/ig, ''
    email = email[...20]
    email += '.r' + uuid.v1().split('-')[0] + (Math.random()*10**18).toString(36)[...2] + '@mail.jianliao.com'
    email.toLowerCase()

  refreshGuestToken: -> uuid.v1().split('-')[0] + (Math.random()*10**18).toString(36)[...2]
