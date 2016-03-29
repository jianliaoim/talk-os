path = require('path')
webpackConfig = require('./packing/webpack-dev.coffee')({__dirname: __dirname, env: 'static'})
webpackConfig.plugins = [] # plugins are not required for testing
delete webpackConfig.entry
webpackConfig.resolve.root = [
  path.resolve('./client')
]
webpackConfig.module.loaders.push
  test: /\.coffee$/
  loader: 'coffee'
  include: path.resolve('./test/spec')
webpackConfig.module.loaders[0] =
  {test: /\.coffee$/, loader: 'coffee', include: [path.resolve('./client'), path.resolve('./config')]}

module.exports = (config) ->
  config.set

    # base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: ''


    # frameworks to use
    # available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine']


    # list of files / patterns to load in the browser
    files: [
      'test/spec/index.js'
    ]


    # list of files to exclude
    exclude: [
    ]


    # preprocess matching files before serving them to the browser
    # available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors:
      'test/spec/*': ['webpack']


    plugins: [
      'karma-webpack'
      'karma-coffee-preprocessor'
      'karma-jasmine'
      'karma-phantomjs-launcher'
    ]


    webpack: webpackConfig


    webpackMiddleware:
      stats:
        colors: true
      noInfo: false
      quiet: true


    # test results reporter to use
    # possible values: 'dots', 'progress'
    # available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['dots']


    reportSlowerThan: 500


    # web server port
    port: 9876


    # enable / disable colors in the output (reporters and logs)
    colors: true


    # level of logging
    # possible values:
    # - config.LOG_DISABLE
    # - config.LOG_ERROR
    # - config.LOG_WARN
    # - config.LOG_INFO
    # - config.LOG_DEBUG
    logLevel: config.LOG_INFO


    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true


    # start these browsers
    # available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS']


    # Continuous Integration mode
    # if true, Karma captures browsers, runs the tests and exits
    singleRun: false
