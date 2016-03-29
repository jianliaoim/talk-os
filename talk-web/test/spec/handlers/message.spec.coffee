Immutable = require 'immutable'

describe 'Handlers: message', ->
  beforeEach ->
    @messageHandler = require 'handlers/message'
    @recorder = require 'actions-recorder'
    spyOn(@recorder, 'getState')

  describe 'Method: remove', ->
    beforeEach ->
      @notifyActions = require 'actions/notify'
      spyOn(@notifyActions, 'info')

    it 'should notify an info: attachment deleted', ->
      store = Immutable.fromJS
        device:
          viewingAttachment: 'attachmentId3'
        messages:
          teamId1:
            roomId2: [
              _id: 'messageId4'
              attachments: [
                _id: 'attachmentId3'
              ]
            ]
      @recorder.getState.and.returnValue store
      actionData = Immutable.fromJS
        _teamId: "teamId1"
        _roomId: "roomId2"
        _id: "messageId4"

      @messageHandler.remove(actionData)

      expect(@notifyActions.info).toHaveBeenCalled()
