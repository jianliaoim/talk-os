require '../../client/main.less'

React = require 'react'
ReactDOM = require 'react-dom'

Markdown = React.createFactory require './markdown'

{div} = React.DOM

Main = React.createClass
  render: ->
    div className: 'app-container',
      Markdown()

ReactDOM.render React.createElement(Main), document.querySelector('#app')
