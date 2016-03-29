o = require 'coffee-object'
webpack = require 'webpack'
SkipPlugin = require 'skip-webpack-plugin'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

fontName = 'fonts/[name].[hash:8].[ext]'
imageName = 'images/[name].[hash:8].[ext]'

webpackDev = require './webpack-dev'

module.exports = (info) ->
  webpackConfig = webpackDev info
  publicPath = if info.useCDN then "#{info.cdn}/" else '/build/'

  entry:
    vendor: ['react', 'react-dom', 'immutable']
    main: [ './client/main', './client/main.less' ]
  output:
    path: 'build/'
    filename: '[name].[chunkhash:8].js'
    publicPath: publicPath
  resolve: webpackConfig.resolve
  module:
    loaders: [
      o test: /\.coffee$/, loader: 'coffee'
      o test: /\.json$/, loader: 'json'
      o test: /\.css$/,
        loader: ExtractTextPlugin.extract('style-loader',
          'css?importLoaders=1!autoprefixer?{browsers:["> 1%"]}')
      o test: /\.less$/,
        loader: ExtractTextPlugin.extract('style-loader',
          'css?importLoaders=1!autoprefixer?{browsers:["> 1%"]}!less')
      o test: /\.(png|jpg|gif)$/,
        loader: 'url'
        query:
          limit: 2048
          name: imageName
      o test: /\.eot((\?|\#)[\?\#\w\d_-]+)?$/,
        loader: 'url'
        query:
          limit: 100
          name: fontName
      o test: /\.svg((\?|\#)[\?\#\w\d_-]+)?$/,
        loader: 'url'
        query:
          limit: 100
          minetype: 'image/svg+xml'
          name: fontName
      o test: /\.ttf((\?|\#)[\?\#\w\d_-]+)?$/,
        loader: 'url'
        query:
          limit: 100
          minetype: 'application/octet-stream'
          name: fontName
      o test: /\.woff((\?|\#)[\?\#\w\d_-]+)?$/,
        loader: 'url'
        query:
          limit: 100
          minetype: 'application/font-woff'
          name: fontName
      o test: /\.woff2((\?|\#)[\?\#\w\d_-]+)?$/,
        loader: 'url'
        query:
          limit: 100
          minetype: 'application/font-woff2'
          name: fontName
    ]
  plugins: [
    new webpack.optimize.CommonsChunkPlugin 'vendor', 'vendor.[chunkhash:8].js'
    new ExtractTextPlugin 'style.[chunkhash:8].css'
    if info.isMinified
      new webpack.DefinePlugin("process.env": {NODE_ENV: JSON.stringify("production")})
    else
      new SkipPlugin info: 'React process.env skipped'
    if info.isMinified
      new webpack.optimize.UglifyJsPlugin(compress: {warnings: false}, sourceMap: false)
    else
      new SkipPlugin info: 'UglifyJsPlugin skipped'
  ]
