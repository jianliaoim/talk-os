
Immutable = require 'immutable'

routerField = Immutable.fromJS
  name: '404'
  data: {}
  query: {}

accountField = Immutable.fromJS
  email: undefined
  phone: undefined
  password: undefined

exports.store = Immutable.fromJS
  router: routerField
  serverError: null
  client:
    account: ''
    password: ''
    isLoading: false
    language: 'zh'
    serverAction: null
    referer: null
  config: {}
  page:
    accounts: null
    captchaService: null
  user: null
