path = require 'path'
fs = require 'fs'
Promise = require 'bluebird'
juice = require 'juice'
jade = require 'jade'
async = require 'async'
ejs = require 'ejs'
config = require 'config'
{logger} = require '../components'

# @osv
# mailguy = require('axon').socket('push')
# mailguy.connect(config.mailguy)

class BaseMailer

  from: '简聊 <notification@mail.jianliao.com>'

  delay: 0

  action: 'delay'

  constructor: ->
    @_getTemplate()

  _sendByRender: (email) ->
    self = this

    if email.html
      return self._send email

    @_render email
    .then (email) ->

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

    mailguy.send _email

  _render: (email) ->
    options =
      cache: true
      filename: path.join __dirname, "../../views/mailers/#{@template}.html"
      delimiter: '?'

    self = this
    template = @_getTemplate()
    Promise.resolve()
    .then ->
      email.html = ejs.render template, email, options
      email

  _cancel: (id) ->
    # @osv
    return id
    mailguy.send action: 'cancel', id: id

  _getTemplate: ->
    unless @_template
      templateFile = path.join __dirname, "../../views/mailers/#{@template}.html"
      template = fs.readFileSync templateFile, encoding: 'utf-8'
      juiceOptions =
        url: "file://" + path.join __dirname, "../../views/mailers"
        preserveMediaQueries: true
      html = ejs.render template, filename: templateFile
      html = juice html, juiceOptions
      html = html.replace /class=[\"|\'].*?[\"\']/ig, ''
      @_template = html
    @_template

module.exports = BaseMailer
