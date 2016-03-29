path = require 'path'
fs = require 'fs'
Promise = require 'bluebird'
juice = require 'juice'
ejs = require 'ejs'
config = require 'config'
logger = require 'graceful-logger'
#
# mailguy = require('axon').socket('push')
# mailguy.connect(config.mailguy)
#
class BaseMailer

  from: '简聊 <notification@mail.jianliao.com>'

  delay: 0

  action: 'delay'

  constructor: ->
    @_getTemplate()

  preview: (email = {}, callback = ->) ->
    self = this

    templateFile = path.join __dirname, "templates/#{@template}.html"
    template = fs.readFileSync templateFile, encoding: 'utf-8'
    juiceOptions =
      url: "file://" + path.join __dirname, "templates"
      preserveMediaQueries: true
      cache: false
    juiceTemplate = ejs.render template, filename: templateFile, cache: false
    juiceTemplate = juice juiceTemplate, juiceOptions
    juiceTemplate = juiceTemplate.replace /class=[\"|\'].*?[\"\']/ig, ''

    filename = path.join __dirname, "templates/#{@template}.html"
    options =
      cache: false
      filename: filename
      delimiter: '?'

    try
      html = ejs.render juiceTemplate, email, options
    catch err
      return callback err
    callback null, html

  _sendByRender: (email) ->
    self = this

    if email.html
      return self._send email

    @_render(email).then (email) ->

      self._send email

    .catch (err) -> logger.warn err.stack

  _send: (email) ->
    # @osv
    return email
    _email =
      from: @from
      to: email.to
      subject: email.subject
      html: email.html
      action: @action
      delay: @delay
      id: email.id

    return if process.env.DEBUG
    mailguy.send _email

  _render: (email) ->
    options =
      cache: true
      filename: path.join __dirname, "templates/#{@template}.html"
      delimiter: '?'

    self = this
    template = @_getTemplate()

    Promise.resolve().then ->
      email.html = ejs.render template, email, options
      email

  _cancel: (id) ->
    # @osv
    return id
    mailguy.send action: 'cancel', id: id

  _getTemplate: ->
    unless @_template
      templateFile = path.join __dirname, "templates/#{@template}.html"
      template = fs.readFileSync templateFile, encoding: 'utf-8'
      juiceOptions =
        url: "file://" + path.join __dirname, "templates"
        preserveMediaQueries: true
      html = ejs.render template, filename: templateFile
      html = juice html, juiceOptions
      html = html.replace /class=[\"|\'].*?[\"\']/ig, ''
      @_template = html
    @_template

module.exports = BaseMailer
