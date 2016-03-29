fs = require('fs')
path = require('path')
config = require 'config'
webpack = require('webpack')
autoprefixer = require 'autoprefixer'
HtmlWebpackPlugin = require 'html-webpack-plugin'

imageName = 'images/[name].[ext]'
fontName = 'fonts/[name].[ext]'

module.exports =
  entry: {
    main: './test/pages/index'
  }
  debug: true
  errorDetails: true
  delay: 50
  output: {
    path: path.resolve('./test/pages/build')
  }
  module: {
    loaders: [
      {test: /\.coffee$/, loader: 'coffee', exclude: /node_modules/},
      {test: /\.less$/, loader: 'style!css!postcss!less'},
      {test: /\.css$/, loader: 'style!css!postcss'},
      {test: /\.json$/, loader: 'json'},
      {test: require.resolve('jquery'), loader: 'expose?jQuery'},
      {test: /\.(png|jpg|gif)$/, loader: 'url', query: {limit: 2048, name: imageName}},
      {test: /\.woff(\?\S*)?$/, loader: "url", query: {limit: 100, minetype: 'application/font-woff', name: fontName}},
      {test: /\.woff2(\?\S*)?$/, loader: "url", query: {limit: 100, minetype: 'application/font-woff2', name: fontName}},
      {test: /\.ttf(\?\S*)?$/, loader: "url", query: {limit: 100, minetype: "application/octet-stream", name: fontName}},
      {test: /\.eot(\?\S*)?$/, loader: "url", query: {limit: 100, name: fontName}},
      {test: /\.svg(\?\S*)?$/, loader: "url", query: {limit: 10000, minetype: "image/svg+xml", name: fontName}},
    ],
    noParse: [
      path.resolve('./node_modules/pdfviewer'),
      path.resolve('./node_modules/jquery'),
      path.resolve('./node_modules/rangy'),
      path.resolve('./node_modules/primus-client/primus.js')
    ]
  },
  resolve: {
    extensions: ['', '.coffee', '.less', '.js']
  },
  plugins: [
    new HtmlWebpackPlugin
      title: 'Test Markdown'
      template: path.resolve('./test/pages/index.html')
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
