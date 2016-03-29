describe 'api', ->

  checkConfig = null

  beforeEach ->
    require 'config'
    @TALK =
      'X-Socket-Id': 'x-socket-id'
      apiHost: '/v1'
      accountUrl: 'account.jianliao.com'
    require.cache[require.resolve('config')].exports = @TALK

    # Mock the urls module so we can test any arbitrary urls
    require 'network/urls'
    require.cache[require.resolve('network/urls')].exports =
      get:
        url1: '/url1'
        url2: '/url2'
        suburl:
          url3: '/subsuburl/url3'
          subsuburl:
            url4: '/suburl/subsuburl/url4'
      post:
        url5: '/url5'
      put:
        url6: '/url6/:id1/test/:id2'

    @urls = require 'network/urls'
    @reqwest = require 'reqwest'
    @api = require 'network/api'

    checkConfig = (config) =>
      expect(@reqwest).toHaveBeenCalled()
      reqwestConfig = @reqwest.calls.mostRecent().args[0]
      expect(reqwestConfig.url).toBe config.url
      expect(reqwestConfig.method).toBe config.method or 'GET'
      expect(reqwestConfig.contentType).toBe 'application/json'
      if config.data
        expect(reqwestConfig.data).toEqual config.data
      expect(reqwestConfig.headers).toEqual {
        'X-Socket-Id': @TALK['X-Socket-Id']
        'X-Language': 'zh'
      }

  it 'should set up urls and call reqwest', ->
    [
      => @api.url1.get()
      => @api.url2.get()
      => @api.suburl.url3.get()
      => @api.suburl.subsuburl.url4.get()
      => @api.url5.post()
    ].forEach (test) =>
      test()
      expect(@reqwest).toHaveBeenCalled()
      @reqwest.calls.reset()

  it 'should call reqwest with the correct configs', ->
    @api.url1.get()
    checkConfig
      url: @TALK.apiHost + @urls.get.url1

  it 'should post data', ->
    config =
      data:
        postData: 123
        postData2: [1, 2, 3]
    @api.url5.post(config)

    checkConfig
      url: @TALK.apiHost + @urls.post.url5
      method: 'POST'
      data: JSON.stringify(config.data)

  # 暂时不检查POST data里面是否有空值，
  # 因为现在有好多地方都有发送空值的习惯，这些错误的地方根本无法检查。
  xit 'should throw an error if post data has bad values', ->
    request = =>
      config =
        data:
          postData: null
          postData2: undefined
      @api.url5.post(config)
    expect(request).toThrowError()
    expect(@reqwest).not.toHaveBeenCalled()

    request = =>
      config =
        data: 123
      @api.url5.post(config)
    expect(request).toThrowError()
    expect(@reqwest).not.toHaveBeenCalled()

  it 'should configure urls with path params', ->
    config =
      pathParams:
        id1: 1
        id2: 2
    @api.url6.put(config)

    checkConfig
      url: @TALK.apiHost + '/url6/1/test/2'
      method: 'PUT'

  it 'should throw an error if path params are invalid', ->
    request = =>
      config =
        pathParams:
          id1: null
          id2: undefined
      @api.url6.put(config)

    expect(request).toThrowError()
    expect(@reqwest).not.toHaveBeenCalled()

  it 'should configure urls with query params', ->
    config =
      queryParams:
        id1: '1'
        id2: '2'
    @api.url1.get(config)

    checkConfig
      url: @TALK.apiHost + '/url1?id1=1&id2=2'

  it 'should throw error if there are invalid query params', ->
    request = =>
      config =
        queryParams:
          id1: null
          id2: undefined
      @api.url1.get(config)

    expect(request).toThrowError()
    expect(@reqwest).not.toHaveBeenCalled()

  it 'should throw an error if it is a GET request but has data provided', ->
    request = =>
      config =
        data: {}
      @api.url1.get(config)
    expect(request).toThrowError()
    expect(@reqwest).not.toHaveBeenCalled()

  it 'should expose a get method: api.get(config)', ->
    url = 'http://test.example.com'
    reqwestConfig =
      url: url
      method: 'GET'
      headers:
        'X-Socket-Id': @TALK['X-Socket-Id']
        'X-Language': 'zh'

    @api.get(url)
    expect(@reqwest).toHaveBeenCalledWith reqwestConfig

  # can't mock window.location, will fix it later
  xdescribe '403 session timeout', ->
    error = errorHandler = accountActions = null

    beforeEach ->
      error =
        status: 403
      spyOn(window.location, 'replace')
      @api.url1.get()
      errorHandler = @reqwest.calls.mostRecent().args[0].error

    it 'should log out', ->
      errorHandler(error)
      jasmine.clock().tick(3000)
      expect(window.location.replace).toHaveBeenCalledWith @TALK.accountUrl

    it 'should notify and then log out after 3 seconds', ->
      notifyActions = require 'actions/notify'
      spyOn(notifyActions, 'error')

      errorHandler(error)
      expect(notifyActions.error).toHaveBeenCalled()
      jasmine.clock().tick(3000)
      expect(window.location.replace).toHaveBeenCalledWith @TALK.accountUrl

    it 'should do nothing if other error status', ->
      error =
        status: 404
      errorHandler(error)
      expect(window.location.replace).not.toHaveBeenCalled()
      jasmine.clock().tick(3000)
      expect(window.location.replace).not.toHaveBeenCalled()
