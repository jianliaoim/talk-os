fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
gutil = require 'gulp-util'
config = require 'config'
webpack = require 'webpack'
sequence = require 'run-sequence'
WebpackDevServer = require 'webpack-dev-server'

env = process.env.NODE_ENV

gulp.task 'html', (cb) ->
  template = require './entry/template'
  assetLinks = require './packing/asset-links'

  html = template(assetLinks, config)
  fs.writeFile 'build/index.html', html, cb

gulp.task 'clean', (cb) ->
  del = require 'del'

  del ['build'], cb

# Webpack tasks

gulp.task 'webpack-dev', (cb) ->
  webpackDev = require './packing/webpack-dev'
  webpackServer =
    publicPath: '/'
    hot: true
    stats:
      colors: true
  info =
    __dirname: __dirname
    env: env

  compiler = webpack (webpackDev info)
  server = new WebpackDevServer compiler, webpackServer

  server.listen config.webpackDevPort, 'talk.bi', (err) ->
    if err?
      throw new gutil.PluginError("webpack-dev-server", err)
    gutil.log "[webpack-dev-server] is listening"
    cb()

gulp.task 'webpack-build', (cb) ->
  webpackBuild = require './packing/webpack-build'
  info =
    __dirname: __dirname
    isMinified: config.isMinified
    isProduction: config.isProduction
    useCDN: config.useCDN
    cdn: config.cdn
    env: env
  webpack (webpackBuild info), (err, stats) ->
    if err
      throw new gutil.PluginError("webpack", err)
    gutil.log '[webpack]', stats.toString()
    fileContent = JSON.stringify stats.toJson().assetsByChunkName
    fs.writeFileSync 'packing/assets.json', fileContent
    cb()

gulp.task 'webpack-test', (cb) ->
  config = require './test/pages/webpack'
  webpackServer =
    publicPath: '/'
    hot: true
    stats:
      colors: true
  compiler = webpack config
  server = new WebpackDevServer compiler, webpackServer

  server.listen 9000, 'localhost', (err) ->
    if err?
      throw new gutil.PluginError("webpack-dev-server", err)
    gutil.log "[webpack-dev-server] is listening"
    cb()

# aliases

gulp.task 'dev', (cb) ->
  sequence 'html', 'webpack-dev', cb

gulp.task 'build', (cb) ->
  gutil.log gutil.colors.yellow("Running Gulp in `#{env}` mode!")
  sequence 'clean', 'webpack-build', 'html', cb

# CDN

gulp.task 'cdn', (cb) ->
  filelog = require 'gulp-filelog'
  upyunDest = require('gulp-upyun').upyunDest

  configFile = path.join __dirname, 'upyun-config.coffee'
  unless fs.existsSync(configFile)
    gutil.log gutil.colors.red("Error: Need upyun config file!")
    process.exit(1)
  options = require './upyun-config'
  gulp.src('build/**/*')
  .pipe filelog('Uploading to Upyun')
  .pipe upyunDest('dn-st/talk-web', options)
  .on 'error', gutil.log

# coffeelint

gulp.task 'lint', ->
  coffeelint = require 'gulp-coffeelint'
  gulpFilter = require 'gulp-filter'

  filter = gulpFilter ['**', '!**/en.coffee', '!**/zh.coffee', '!**/zh-tw.coffee',
    "!**/module/icons.coffee"
  ]

  gulp.src('./client/**/*.coffee')
  .pipe filter
  .pipe coffeelint
    max_line_length: {value: 160}
    arrow_spacing: {level: 'warn'}
    eol_last: {level: 'warn'}
    no_empty_param_list: {level: 'warn'}
    no_interpolation_in_single_quotes: {level: 'warn'}
  .pipe coffeelint.reporter()
  .pipe coffeelint.reporter('failOnWarning')
