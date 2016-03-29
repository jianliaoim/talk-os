_envWeb = ->
  @user = 'jarvis'
  @nochdir = true
  @filter = '''
  + package.json
  + build**
  - *
  '''

ossBefore = "gulp cdn"

sneaky 'talk-web:ws', ->
  _envWeb.apply this
  @path = '/usr/local/teambition/talk-web'
  @host = 'dev.talk.ai'
  @before 'npm i && NODE_ENV=ws gulp build'

sneaky 'guest:ws', ->
  _envWeb.apply this
  @path = '/usr/local/teambition/talk-guest-web'
  @host = 'dev.talk.ai'
  @before 'npm i && APP=guest NODE_ENV=ws gulp build'

sneaky 'talk-web:beta', ->
  _envWeb.apply this
  @path = '/data/app/talk-web'
  @host = '115.29.230.208'
  @before "npm i && NODE_ENV=beta gulp build"

sneaky 'talk-web:ga', ->
  _envWeb.apply this
  @filter = '''
  + build
  + build/index.html
  - *
  '''
  @path = '/usr/local/teambition/talk-web-ga'
  @host = 'talk.ai'
  @before "npm i && NODE_ENV=ga gulp build && #{ossBefore}"

sneaky 'guest:ga', ->
  _envWeb.apply this
  @filter = '''
  + build
  + build/index.html
  - *
  '''
  @path = '/usr/local/teambition/talk-guest-web-ga'
  @host = 'talk.ai'
  @before "npm i && APP=guest NODE_ENV=ga gulp build && gulp cdn"

sneaky 'guest:prod', ->
  _envWeb.apply this
  @filter = '''
  + build
  + build/index.html
  - *
  '''
  @path = '/usr/local/teambition/talk-guest-web'
  @host = 'talk.ai'
  @before "npm i && APP=guest NODE_ENV=prod gulp build && gulp cdn"

sneaky 'talk-web:prod', ->
  _envWeb.apply this
  @filter = '''
  + build
  + build/index.html
  - *
  '''
  @path = '/usr/local/teambition/talk-web'
  @host = 'talk.ai'
  @before "npm i && NODE_ENV=prod gulp build && #{ossBefore}"
