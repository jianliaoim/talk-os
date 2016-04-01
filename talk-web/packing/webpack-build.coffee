
webpack = require('webpack')
SkipPlugin = require 'skip-webpack-plugin'
ExtractTextPlugin = require('extract-text-webpack-plugin')
autoprefixer = require 'autoprefixer'
cssnano = require 'cssnano'
config = require 'config'

webpackDev = require './webpack-dev'

imageName = 'images/[name].[hash:8].[ext]'
fontName = 'fonts/[name].[hash:8].[ext]'

if process.env.APP is 'guest'
  main = './client/guest/main.coffee'
else
  main = './client/main.coffee'

module.exports = (info) ->
  webpackConfig = webpackDev info
  publicPath = if info.useCDN then "#{info.cdn}/talk-web/" else '/'

  # returns object
  entry: {
    vendor: webpackConfig.entry.vendor.slice(2) # drop dev scripts
    main: webpackConfig.entry.main
  },
  debug: false,
  output: {
    path: 'build/',
    filename: 'js/[name].[chunkhash:8].js',
    publicPath: publicPath
  },
  module: {
    loaders: [
      {test: /\.coffee$/, loader: 'coffee', exclude: /node_modules/},
      {test: /\.less$/, loader: ExtractTextPlugin.extract('style-loader', 'css!postcss!less')},
      {test: /\.css$/, loader: ExtractTextPlugin.extract('style-loader', 'css!postcss')},
      {test: /\.json$/, loader: 'json'},
      {test: require.resolve('jquery'), loader: 'expose?jQuery'},
      {test: /\.(png|jpg|gif)$/, loader: 'url', query: {limit: 2048, name: imageName}},
      {test: /\.woff(\?\S*)?$/, loader: "url", query: {limit: 100, mimetype: 'application/font-woff', name: fontName}},
      {test: /\.woff2(\?\S*)?$/, loader: "url", query: {limit: 100, mimetype: 'application/font-woff2', name: fontName}},
      {test: /\.ttf(\?\S*)?$/, loader: "url", query: {limit: 100, mimetype: "application/octet-stream", name: fontName}},
      {test: /\.eot(\?\S*)?$/, loader: "url", query: {limit: 100, name: fontName}},
      {test: /\.svg(\?\S*)?$/, loader: "url", query: {limit: 10000, mimetype: "image/svg+xml", name: fontName}},
    ]
  },
  externals: webpackConfig.externals,
  resolve: webpackConfig.resolve,
  plugins: [
    new ExtractTextPlugin('css/[name].[chunkhash:8].css')
    new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /(zh-cn|en|zh-tw)$/)
    if info.isProduction
      new webpack.DefinePlugin("process.env": {NODE_ENV: JSON.stringify("production")})
    else
      new SkipPlugin info: 'React process.env skipped'
    new webpack.optimize.CommonsChunkPlugin('vendor', 'js/vendor.[chunkhash:8].js')
    if info.isMinified
      new webpack.optimize.UglifyJsPlugin(compress: {warnings: false}, sourceMap: false)
    else
      new SkipPlugin info: 'UglifyJsPlugin skipped'
    new webpack.DefinePlugin
      __DEV__: config.env in ['ws', 'dev']
      __GA__: config.env in ['ga', 'ws', 'dev']
  ]
  postcss: ->
    [
      autoprefixer(browsers: ['last 2 versions', '> 1%'])
      cssnano()
    ]
