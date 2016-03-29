fs = require 'fs'
del = require 'del'
gulp = require 'gulp'
path = require 'path'
gutil = require 'gulp-util'
config = require 'config'
sequence = require 'run-sequence'
webpack = require 'webpack'
sequence = require 'run-sequence'
WebpackDevServer = require 'webpack-dev-server'

gulp.task 'del', (cb) ->
  del 'build', cb

# cdn

gulp.task 'cdn', (cb) ->
  filelog = require 'gulp-filelog'
  upyunDest = require('gulp-upyun').upyunDest

  configFile = path.join __dirname, 'upyun-config.coffee'
  unless fs.existsSync(configFile)
    throw new Error 'Need upyun config file!'
  options = require './upyun-config'
  gulp.src('build/**/*')
  .pipe filelog('Uploading to Upyun')
  .pipe upyunDest('dn-st/talk-account', options)
  .on 'error', gutil.log

# webpack

gulp.task 'webpack-dev', (cb) ->
  webpackDev = require './client/packing/webpack-dev'
  webpackServer =
    publicPath: '/'
    hot: true
    stats:
      colors: true
  info =
    __dirname: __dirname
    env: config.env

  compiler = webpack (webpackDev info)
  server = new WebpackDevServer compiler, webpackServer

  server.listen config.webpackDevPort, '0.0.0.0', (err) ->
    if err?
      throw new gutil.PluginError("webpack-dev-server", err)
    gutil.log "[webpack-dev-server] is starting..."
    cb()

gulp.task 'webpack-build', (cb) ->
  webpackBuild = require './client/packing/webpack-build'
  info =
    __dirname: __dirname
    isMinified: config.isMinified
    useCDN: config.useCDN
    cdn: config.cdn
    env: config.env
  webpack (webpackBuild info), (err, stats) ->
    if err
      gutil.log gutil.PluginError("webpack", err)
      process.exit 1 # so followed scripts may capture it
    gutil.log '[webpack]', stats.toString()
    fileContent = JSON.stringify stats.toJson().assetsByChunkName
    fs.writeFileSync 'client/packing/assets.json', fileContent
    cb()

# aliases

gulp.task 'dev', (cb) ->
  sequence 'webpack-dev', cb

gulp.task 'build', (cb) ->
  gutil.log gutil.colors.yellow("Running Gulp in `#{config.env}` mode!")
  sequence 'del', 'webpack-build', cb
