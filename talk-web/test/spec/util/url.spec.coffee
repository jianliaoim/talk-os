describe 'util: url', ->

  beforeEach ->
    @url = require 'util/url'

  describe 'function: isInRoutes:', ->
    url = null

    beforeEach ->
      url = 'http://jianliao.com' # location.origin

    it 'should match jianliao urls', ->
      href = 'http://jianliao.com'
      expect(@url.isInRoutes(url, href)).toBe true

      href = 'http://jianliao.com/'
      expect(@url.isInRoutes(url, href)).toBe true

      href = 'http://jianliao.com/team/xxx'
      expect(@url.isInRoutes(url, href)).toBe true

      href = 'http://jianliao.com/team/xxx/room/yyy'
      expect(@url.isInRoutes(url, href)).toBe true

    it 'should not match jianliao short url', ->
      href = 'http://jianliao.com/t/shorturl'
      expect(@url.isInRoutes(url, href)).toBe false

    it 'should not match /site', ->
      href = 'http://jianliao.com/site'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/site/xxx'
      expect(@url.isInRoutes(url, href)).toBe false

    it 'should not match /blog', ->
      href = 'http://jianliao.com/blog'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/blog/xxx'
      expect(@url.isInRoutes(url, href)).toBe false

    it 'should not match /doc', ->
      href = 'http://jianliao.com/doc'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/doc/xxx'
      expect(@url.isInRoutes(url, href)).toBe false

    it 'should not match /page', ->
      href = 'http://jianliao.com/page'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/page/xxx'
      expect(@url.isInRoutes(url, href)).toBe false

    it 'should not match api /v\d', ->
      href = 'http://jianliao.com/v1'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/v2'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/v3'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/v1/xxx'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/v2/xxx'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://jianliao.com/v3/xxx'
      expect(@url.isInRoutes(url, href)).toBe false

    it 'should not match normal urls', ->
      href = 'http://example.com'
      expect(@url.isInRoutes(url, href)).toBe false

      href = 'http://test.com/site'
      expect(@url.isInRoutes(url, href)).toBe false
