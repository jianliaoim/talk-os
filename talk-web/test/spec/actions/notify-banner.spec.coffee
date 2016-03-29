xdescribe 'Actions: notify-banner', ->

  beforeEach ->
    @action = require 'actions/notify-banner'
    @dispatcher = require 'dispatcher'
    spyOn @dispatcher, 'handleViewAction'

  describe 'Method: warn, error, info, success', ->
    it 'should create notificiation', ->
      text = 'test'
      ['warn', 'error', 'info', 'success'].forEach (method) =>
        @action[method](text)
        dispatchData =
          type: 'notify-banner/create'
          data:
            type: method
            text: text
        expect(@dispatcher.handleViewAction).toHaveBeenCalledWith dispatchData

  describe 'Method: clear', ->
    it 'should clear notificiation', ->
      dispatchData =
        type: 'notify-banner/clear'
      @action.clear()
      expect(@dispatcher.handleViewAction).toHaveBeenCalledWith dispatchData
