o = require 'coffee-object'
path = require 'path'
config = require 'config'
webpack = require 'webpack'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

fontName = 'fonts/[name].[hash:8].[ext]'
imageName = 'images/[name].[hash:8].[ext]'

module.exports = (info) ->
  entry:
    vendor: [
      "webpack-dev-server/client?http://0.0.0.0:#{config.webpackDevPort}", 'webpack/hot/dev-server'
      'react', 'react-dom', 'immutable' ]
    main: [ './client/main', './client/main.less' ]
  output:
    path: path.join info.__dirname, 'build' # build/ at project root
    filename: '[name].js'
    publicPath: "http://#{config.resourceDomain}:#{config.webpackDevPort}/"
  delay: 50
  resolve:
    extensions: ['', '.coffee', '.js', '.json', '.less']
  module:
    loaders: [
      o test: /\.coffee$/, loader: 'react-hot!coffee'
      o test: /\.json$/, loader: 'json'
      o test: /\.less$/,
        loader: 'style!css?importLoaders=1!autoprefixer!less'
      o test: /\.css$/,
        loader: 'style!css?importLoaders=1!autoprefixer'
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
    new webpack.optimize.CommonsChunkPlugin 'vendor', 'vendor.js'
    new webpack.HotModuleReplacementPlugin()
    new webpack.NoErrorsPlugin()
  ]
