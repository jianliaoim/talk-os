crypto = require 'crypto'
uuid = require 'uuid'

module.exports = _crypto =
  md5: (str) ->
    crypto.createHash('md5').update(str).digest('hex')
  sha1: (str) ->
    crypto.createHash('sha1').update(str).digest('hex')
  # @param `raw_password` user input
  # @param `enc_password` password store in the database
  checkPassword: (raw_password, enc_password) ->
    args = []
    if '$' not in enc_password
      if raw_password is enc_password then true else false
    else
      pass = enc_password.split('$')
      for i in [0..pass.length - 1]
        args[i] = pass[i]
      en = crypto.createHash('sha1').update(args[1] + raw_password).digest('hex')
      if en is args[2] then true else false

  encryptPassword: (raw_password) ->
    type = 'sha1'
    mix = crypto.createHash('sha1').update(Math.random().toString()).digest('hex')[0...6]
    encode = crypto.createHash('sha1').update(mix + raw_password).digest('hex')
    return [type, mix, encode].join('$')

  encrypt: (str, secret) ->
    m = crypto.createHash('md5')
    m.update(secret)
    key = m.digest('hex')

    m = crypto.createHash('md5')
    m.update(secret + key)
    iv = m.digest('hex')

    data = new Buffer(str, 'utf8').toString('binary')

    cipher = crypto.createCipheriv('aes-256-cbc', key, iv.slice(0, 16))
    encrypted = cipher.update(data, 'utf8', 'hex') + cipher.final('hex')
    encoded = new Buffer(encrypted, 'binary').toString()
    return encoded

  decrypt: (str, secret) ->
    try
      input = str.replace(/\-/g, '+').replace(/_/g, '/')
      edata = new Buffer(input, 'utf8').toString('binary')

      m = crypto.createHash('md5')
      m.update(secret)
      key = m.digest('hex')

      m = crypto.createHash('md5')
      m.update(secret + key)
      iv = m.digest('hex')

      decipher = crypto.createDecipheriv('aes-256-cbc', key, iv.slice(0, 16))
      decrypted = decipher.update(edata, 'hex', 'utf8') + decipher.final('utf8')
      plaintext = new Buffer(decrypted, 'binary').toString('utf8')
    catch e
      plaintext = null
    return plaintext

  encryptToken: (str, secret) ->
    _crypto.encrypt.apply this, arguments

  decryptToken: (str, secret) ->
    plaintext = _crypto.decrypt str, secret
    return null unless plaintext
    [userId, timestamp] = plaintext.split('$')
    data =
      userId: userId
      timestamp: timestamp
    return data
