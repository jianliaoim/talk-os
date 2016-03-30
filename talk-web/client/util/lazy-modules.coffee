
# 异步加载的计划, 通过异步加载模块的方式控制代码
# controller 当中异步加载并 define 组件
# renderer 当中 load 组件用户渲染
# 代码有点 tricky 而且用设计模式和可变对象, 而不是纯函数的手法, 谨慎使用

React = require 'react'

analytics = require './analytics'

lazyModules = {}

exports.define = (moduleName, module) ->
  lazyModules[moduleName] = module

exports.load = (moduleName) ->
  lazyModules[moduleName]

exports.ensureCodeEditor = (cb) ->
  requireStartTime = (new Date).valueOf()
  require.ensure [], ->
    exports.define 'codemirror', require './codemirror'
    exports.define 'code-editor', React.createFactory require '../module/code-editor'
    exports.define 'snippet-selector', React.createFactory require '../app/snippet-selector'
    analytics.compareRequireCost requireStartTime, 'snippet-editor'
    cb?()
