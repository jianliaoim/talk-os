server = require '../server/server'

before (done) -> setTimeout done, 500

require './io'
