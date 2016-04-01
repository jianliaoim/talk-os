
fs = require('fs')
path = require('path')
config = require 'config'
webpack = require('webpack')
autoprefixer = require 'autoprefixer'

imageName = 'images/[name].[ext]'
fontName = 'fonts/[name].[ext]'

if process.env.APP is 'guest'
  main = './client/guest/main.coffee'
else
  main = './client/main.coffee'

module.exports = (info) ->

  # returns
  entry: {
    main: main,
    vendor: [
      "webpack-dev-server/client?http://talk.bi:#{config.webpackDevPort}",
      'webpack/hot/dev-server'
      './client/vendor/primus'
      'actions-recorder', 'base-64', 'classnames', 'cookie_js', 'debounce'
      'favico.js', 'fileapi', 'filesize', 'highlight.js/lib/highlight'
      'immutable', 'keycode', 'lodash.isequal', 'lodash.ismatch', 'lodash.uniq'
      'markdown-it', 'markdown-it-attrs', 'markdown-it-emoji', 'moment', 'object-assign'
      'pinyin', 'q', 'qrcode-generator', 'react'
      'react-addons-css-transition-group', 'react-addons-linked-state-mixin'
      'react-addons-pure-render-mixin', 'react-addons-transition-group'
      'react-dom', 'react-textarea-autosize'
      'reqwest', 'router-view', 'shortid', 'smoothscroll-polyfill'
      'talk-msg-dsl', 'tether-drop', 'tether-shepherd'
      'type-of', 'utf8', 'wolfy87-eventemitter', 'xss'
    ]
  },
  debug: true,
  devtool: 'eval-source-map',
  errorDetails: true
  delay: 50,
  output: {
    path: path.join info.__dirname, 'build' # build/ at project root
    publicPath: "http://talk.bi:#{config.webpackDevPort}/",
    filename: '[name].js'
  },
  module: {
    loaders: [
      {test: /\.coffee$/, loader: 'coffee', exclude: /node_modules/},
      {test: /\.less$/, loader: 'style!css?sourceMap!postcss!less?sourceMap'},
      {test: /\.css$/, loader: 'style!css?sourceMap!postcss'},
      {test: /\.json$/, loader: 'json'},
      {test: require.resolve('jquery'), loader: 'expose?jQuery'},
      {test: /\.(png|jpg|gif)$/, loader: 'url', query: {limit: 2048, name: imageName}},
      {test: /\.woff(\?\S*)?$/, loader: "url", query: {limit: 100, mimetype: 'application/font-woff', name: fontName}},
      {test: /\.woff2(\?\S*)?$/, loader: "url", query: {limit: 100, mimetype: 'application/font-woff2', name: fontName}},
      {test: /\.ttf(\?\S*)?$/, loader: "url", query: {limit: 100, mimetype: "application/octet-stream", name: fontName}},
      {test: /\.eot(\?\S*)?$/, loader: "url", query: {limit: 100, name: fontName}},
      {test: /\.svg(\?\S*)?$/, loader: "url", query: {limit: 10000, mimetype: "image/svg+xml", name: fontName}},
    ],
    noParse: [
      path.resolve('./node_modules/pdfviewer'),
      path.resolve('./node_modules/jquery'),
      path.resolve('./node_modules/rangy'),
      path.resolve('./node_modules/primus-client/primus.js')
    ]
  },
  externals: {
  },
  resolve: {
    extensions: ['', '.coffee', '.less', '.js']
  },
  plugins: [
    new webpack.optimize.CommonsChunkPlugin('vendor', 'vendor.js')
    new webpack.HotModuleReplacementPlugin()
    new webpack.NoErrorsPlugin()
    new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /(zh-cn|en|zh-tw)$/)
    new webpack.DefinePlugin
      __DEV__: true
      __GA__: true
  ]
  postcss: ->
    [
      autoprefixer browsers: ['last 2 versions', '> 1%']
    ]
