
recorder = require 'actions-recorder'
dispatcher = require '../dispatcher'

lang = require '../locales/lang'
utilUrl = require '../util/url'

notifyActions = require '../actions/notify'
api = require '../network/api'

exports.inteFetch = (_teamId, success, fail) ->
  api.integrations.read.get(queryParams: _teamId: _teamId)
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'inte/fetch'
        data:
          _teamId: _teamId
          resp: resp
      success? resp
    .catch (error) ->
      fail? error

exports.inteUpdate = (_inteId, data, success, fail) ->
  config =
    pathParams:
      id: _inteId
    data: data
  api.integrations.update.put(config)
    .then (resp) ->
      dispatcher.handleViewAction type: 'inte/update', data: resp
      success? resp
    .catch (error) ->
      notifyActions.error lang.getText('failed-update-integration')
      fail? error

exports.inteCreate = (data, success, fail) ->
  api.integrations.create.post(data: data)
    .then (resp) ->
      resp.isNew = true
      dispatcher.handleViewAction
        type: 'inte/create'
        data: resp
      success? resp
    .catch (error) ->
      notifyActions.error lang.getText('failed-create-integration')
      fail? error

exports.inteRemove = (inte, success, fail) ->
  api.integrations.remove.delete(pathParams: id: inte.get('_id'))
    .then (resp) ->
      dispatcher.handleViewAction
        type: 'inte/remove'
        data: inte
      success? resp
    .catch (error) ->
      fail? error

exports.checkRss = (url, success, fail) ->
  api.integrations.checkrss.get(queryParams: url: url)
    .then (resp) ->
      success? resp
    .catch (error) ->
      fail? error

exports.getSettings = (success, fail) ->
  api.services.settings.get()
    .then (resp) ->
      email =
        iconUrl: utilUrl.emailIcon
        name: 'email'
        template: ''
        isCustomized: false
        manual: false
        title: lang.getText('inte-email')
        summary:
          zh: lang.getText('inte-email-summary', 'zh')
          en: lang.getText('inte-email-summary', 'en')
        description:
          zh: lang.getText('inte-email-description', 'zh')
          en: lang.getText('inte-email-description', 'en')
      resp.unshift email
      recorder.dispatch 'inte/settings', resp
      success? resp
    .catch (error) ->
      fail? error
      notifyActions.error lang.getText('api-failed')
