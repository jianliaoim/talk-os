fs = require 'fs'
stir = require 'stir-template'
React = require 'react'
ReactDOMServer = require 'react-dom/server'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

ContainerWireframe = React.createFactory require '../client/app/container-wireframe'

schema = require '../client/schema'

baidu = fs.readFileSync 'entry/baidu.html'
mixpanel = fs.readFileSync 'entry/mixpanel.html'
googleAnalytics = fs.readFileSync 'entry/google-analytics.html'
cssLoading = fs.readFileSync 'entry/loading.css'
triggerLoading = fs.readFileSync 'entry/triggerLoading.js'

{html, head, title, body, script, meta, link, div} = stir
style = stir.createFactory 'style'

module.exports = (assets, config) ->

  initialStore = schema.database.set 'config', Immutable.fromJS(config)

  recorder.setup
    initial: initialStore
    updater: (x) -> x # updater is not called in rendering template
    inProduction: false

  store = recorder.getStore()

  stir.render stir.doctype(),
    html null,
      head null,
        title null, '简聊'
        meta charset: 'utf-8'
        meta 'http-equiv': 'X-UA-Compatible', content: 'IE=edge, chrome=1'
        meta name: 'referrer', content: 'origin-when-cross-origin'
        meta name: 'superfish', content: 'nofish'
        meta name: 'author', content: '简聊'
        meta name: 'description', content: '简聊是一个团队协作即时通讯工具, 拥有多种消息文本类型, 话题, 内容分享, 搜索, 文件整理以及一系列精彩的功能. 我们希望你的团队能通过简聊变得更有效率'
        meta name: 'keywords', content: '分享, 工作, 沟通, 话题, 即使通讯, 团队协作, 效率'
        meta name: 'apple-itunes-app', content: 'app-id=922425179'
        meta property: 'og:description', content: '简聊是一个团队协作即时通讯工具, 拥有多种消息文本类型, 话题, 内容分享, 搜索, 文件整理以及一系列精彩的功能. 我们希望你的团队能通过简聊变得更有效率'
        meta property: 'og:image', content: 'https://dn-talk.oss.aliyuncs.com/icons/preview.png'
        meta property: 'og:site_name', content: '简聊'
        meta property: 'og:title', content: '简聊 | 谈工作，用简聊'
        meta property: 'og:type', content: 'website'
        meta property: 'og:url', content: 'https://jianliao.com'
        link rel: 'shortcut icon', type: 'image/x-icon', href: '/favicon.ico'
        if assets.style?
          link rel: 'stylesheet', type: 'text/css', href: assets.style
        style null, cssLoading
      body null,
        div class: 'app',
          ReactDOMServer.renderToStaticMarkup ContainerWireframe(sentence: '')
        script null, "window._initialStore = (#{JSON.stringify(store)});"
        script null, triggerLoading
        googleAnalytics if config.useAnalytics
        mixpanel if config.useAnalytics
        baidu if config.useAnalytics
        script crossorigin:"anonymous", src: assets.vendor
        script crossorigin:"anonymous", src: assets.main
