module.exports =
  debug: true
  env: 'test'
  # testPhoneNumber: '18500000000'
  # Connections
  mongo:
    address: 'mongodb://localhost:27017/talk_account_test'
    authdb: 'admin'
  redis:
    host: 'localhost'
    port: 6379
    db: 5
