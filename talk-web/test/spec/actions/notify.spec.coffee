xdescribe 'Actions: notify', ->

  beforeEach ->
    @action = require 'actions/notify'
    @dispatcher = require 'dispatcher'
    spyOn @dispatcher, 'handleViewAction'

  describe 'Method: warn, error, info, success', ->
    it 'should create notificiation', ->
      text = 'test'
      ['warn', 'error', 'info', 'success'].forEach (method) =>
        @action[method](text)
        dispatchData =
          type: 'notify/create'
          data:
            type: method
            text: text
            config: {}
        expect(@dispatcher.handleViewAction).toHaveBeenCalledWith dispatchData

    it 'should provide configs', ->
      text = 'test'
      config =
        isSticky: true
      ['warn', 'error', 'info', 'success'].forEach (method) =>
        @action[method](text, config)
        dispatchData =
          type: 'notify/create'
          data:
            type: method
            text: text
            config: config
        expect(@dispatcher.handleViewAction).toHaveBeenCalledWith dispatchData

  describe 'Method: remove', ->
    it 'should remove notificiation', ->
      _id = '1'
      dispatchData =
        type: 'notify/remove'
        data:
          _id: _id
      @action.remove(_id)
      expect(@dispatcher.handleViewAction).toHaveBeenCalledWith dispatchData
