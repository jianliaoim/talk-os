describe 'util: emoji', ->

  beforeEach ->
    @emoji = require 'util/emoji'

  describe 'function: replace', ->
    it 'should handle normal text', ->
      text = 'hahaha\nhahaha'
      expect(@emoji.replace(text)).toEqual 'hahaha\nhahaha'

    it 'should replace simple emoji', ->
      text = ':smile:'
      expect(@emoji.replace(text)).toEqual '<img align="absmiddle" alt=":smile:" class="emoji" src="https://dn-talk.oss.aliyuncs.com/icons/emoji/smile.png>'

    it 'should replace emoji with text', ->
      text = 'hi :smile: hi'
      expect(@emoji.replace(text)).toEqual 'hi <img align="absmiddle" alt=":smile:" class="emoji" src="https://dn-talk.oss.aliyuncs.com/icons/emoji/smile.png> hi'

    it 'should replace concatenated emojis', ->
      text = 'hi:smile:hi'
      expect(@emoji.replace(text)).toEqual 'hi<img align="absmiddle" alt=":smile:" class="emoji" src="https://dn-talk.oss.aliyuncs.com/icons/emoji/smile.png>hi'

      text = ':smile::smile::smile:'
      expect(@emoji.replace(text)).toEqual
        '<img align="absmiddle" alt=":smile:" class="emoji" src="https://dn-talk.oss.aliyuncs.com/icons/emoji/smile.png><img align="absmiddle" alt=":smile:" class="emoji" src="https://dn-talk.oss.aliyuncs.com/icons/emoji/smile.png><img align="absmiddle" alt=":smile:" class="emoji" src="https://dn-talk.oss.aliyuncs.com/icons/emoji/smile.png>'

    it 'should handle unicode', ->
      text = '你好:smile:你好'
      expect(@emoji.replace(text)).toEqual '你好<span class="emoji emoji-smile"></span>你好'

    it 'should newlines unicode', ->
      text = 'hi\n:smile:\nhi'
      expect(@emoji.replace(text)).toEqual 'hi\n<span class="emoji emoji-smile"></span>\nhi'

    it 'should not replace unsupported emoji', ->
      text = 'hi:bowtie:hi'
      expect(@emoji.replace(text)).toEqual 'hi:bowtie:hi'
