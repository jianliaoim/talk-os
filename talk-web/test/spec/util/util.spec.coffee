Immutable = require 'immutable'

describe 'util: util', ->

  beforeEach ->
    @util = require 'util/util'

  describe 'function: combineMessages', ->
    it 'should combine creators when the body is the same and it is a system message', ->
      messages = Immutable.fromJS [
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'a', name: 'a'}}
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'b', name: 'b'}}
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'c', name: 'c'}}
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'd', name: 'd'}}
      ]

      combined = Immutable.fromJS [
        {
          body: '{{_info-join-team}}'
          isSystem: true
          creators: [
            {_id: 'a', name: 'a'}
            {_id: 'b', name: 'b'}
            {_id: 'c', name: 'c'}
            {_id: 'd', name: 'd'}
          ]
        }
      ]
      expect(@util.combineMessages(messages)).toEqualImmutable combined

    it 'should not do anything if there are no messages', ->
      messages = Immutable.fromJS []
      combined = Immutable.fromJS []
      expect(@util.combineMessages(messages)).toEqualImmutable combined

    it 'should not do anything if there are one message', ->
      messages = Immutable.fromJS [
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'a', name: 'a'}}
      ]
      combined = Immutable.fromJS [
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'a', name: 'a'}}
      ]
      expect(@util.combineMessages(messages)).toEqualImmutable combined

    it 'should handle mixed messages', ->
      messages = Immutable.fromJS [
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'a', name: 'a'}}
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'b', name: 'b'}}
        {body: 'test', isSystem: false, creator: {_id: 'c', name: 'c'}}
        {body: '{{_info-leave-team}}', isSystem: true, creator: {_id: 'd', name: 'd'}}
        {body: '{{_info-leave-team}}', isSystem: true, creator: {_id: 'e', name: 'e'}}
        {body: 'test', isSystem: false, creator: {_id: 'f', name: 'f'}}
        {body: 'test', isSystem: false, creator: {_id: 'g', name: 'g'}}
      ]
      combined = Immutable.fromJS [
        {
          body: '{{_info-join-team}}'
          isSystem: true
          creators: [
            {_id: 'a', name: 'a'}
            {_id: 'b', name: 'b'}
          ]
        }
        {body: 'test', isSystem: false, creator: {_id: 'c', name: 'c'}}
        {
          body: '{{_info-leave-team}}'
          isSystem: true
          creators: [
            {_id: 'd', name: 'd'}
            {_id: 'e', name: 'e'}
          ]
        }
        {body: 'test', isSystem: false, creator: {_id: 'f', name: 'f'}}
        {body: 'test', isSystem: false, creator: {_id: 'g', name: 'g'}}
      ]
      expect(@util.combineMessages(messages)).toEqualImmutable combined

    it 'should combine creators if message and creator is the same', ->
      messages = Immutable.fromJS [
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'a', name: 'a'}}
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'a', name: 'a'}}
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'b', name: 'b'}}
        {body: '{{_info-join-team}}', isSystem: true, creator: {_id: 'b', name: 'b'}}
      ]

      combined = Immutable.fromJS [
        {
          body: '{{_info-join-team}}'
          isSystem: true
          creators: [
            {_id: 'a', name: 'a'}
            {_id: 'b', name: 'b'}
          ]
        }
      ]
      expect(@util.combineMessages(messages)).toEqualImmutable combined

  describe 'function: imageRotateScale(imageWidth, imageHeight, containerWidth, containerHeight)', ->
    it 'original image is smaller than container', ->
      [iWidth, iHeight, cWidth, cHeight] = [200, 200, 200, 300]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe 1

      [iWidth, iHeight, cWidth, cHeight] = [100, 100, 200, 300]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe 1

      [iWidth, iHeight, cWidth, cHeight] = [200, 200, 300, 200]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe 1

      [iWidth, iHeight, cWidth, cHeight] = [100, 100, 300, 200]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe 1

    it 'iHeight > iWidth (1)', ->
      [iWidth, iHeight, cWidth, cHeight] = [500, 1000, 600, 550]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe (cWidth / cHeight)

    it 'iHeight > iWidth (2)', ->
      [iWidth, iHeight, cWidth, cHeight] = [8, 730, 1100, 700]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe (iHeight / cHeight)

    it 'iHeight > iWidth (3)', ->
      [iWidth, iHeight, cWidth, cHeight] = [3260, 2450, 1100, 660]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe (iHeight / iWidth)

    it 'iHeight > iWidth (4)', ->
      [iWidth, iHeight, cWidth, cHeight] = [3260, 2450, 230, 375]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe (iWidth / iHeight)

    it 'iHeight <= iWidth (1)', ->
      [iWidth, iHeight, cWidth, cHeight] = [1000, 500, 550, 600]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe (cHeight / cWidth)

    it 'iHeight <= iWidth (2)', ->
      [iWidth, iHeight, cWidth, cHeight] = [730, 8, 700, 1100]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe (iWidth / cWidth)

    it 'iHeight <= iWidth (3)', ->
      [iWidth, iHeight, cWidth, cHeight] = [3260, 2450, 660, 1100]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe (iWidth / iHeight)

    it 'iHeight <= iWidth (4)', ->
      [iWidth, iHeight, cWidth, cHeight] = [2450, 3260, 375, 230]
      scale = @util.imageRotateScale(iWidth, iHeight, cWidth, cHeight)
      expect(scale).toBe (iHeight / iWidth)
