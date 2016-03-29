apiFilter = '''
- node_modules
- .git
- test
'''

docFilter = '''
+ doc**
- *
'''

sneaky 'talk-account:ws', ->
  @user = 'jarvis'
  @path = '/usr/local/teambition/talk-account'
  @nochdir = true
  @filter = apiFilter
  @host = 'dev.talk.ai'
  @before 'NODE_ENV=ws gulp build'
  @after 'mkdir -p ../share/node_modules && ln -sfn ../share/node_modules . && npm i --production && pm2 restart talk-account'

sneaky 'talk-account:beta', ->
  @user = 'jarvis'
  @path = '/data/app/talk-account'
  @nochdir = true
  @filter = apiFilter
  @host = '115.29.230.208'
  @before "NODE_ENV=beta gulp build && gulp cdn"
  @after 'mkdir -p ../share/node_modules && ln -sfn ../share/node_modules . && npm i --production && pm2 restart talk-account'

sneaky 'talk-account:ga', ->
  @user = 'jarvis'
  @path = '/usr/local/teambition/talk-account-ga'
  @nochdir = true
  @filter = apiFilter
  @host = 'talk.ai'
  @version = 'master'
  @before 'NODE_ENV=ga gulp build && gulp cdn'
  @after 'mkdir -p ../share/node_modules && ln -sfn ../share/node_modules . && npm i --production && pm2 gracefulReload talk-account-ga'

sneaky 'talk-account:prod', ->
  @user = 'jarvis'
  @path = '/usr/local/teambition/talk-account'
  @nochdir = true
  @filter = apiFilter
  @host = 'talk.ai'
  @version = 'release'
  @before 'NODE_ENV=prod gulp build && gulp cdn'
  @after 'mkdir -p ../share/node_modules && ln -sfn ../share/node_modules . && npm i --production && pm2 gracefulReload talk-account'

sneaky 'doc:ws', ->
  @user = 'jarvis'
  @path = '/usr/local/teambition/talk-account-doc'
  @filter = docFilter
  @nochdir = true
  @overwrite = true
  @before 'gitbook build book doc'
  @host = 'dev.talk.ai'
