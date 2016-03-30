require '../../client/main.less'

React = require 'react'
ReactDOM = require 'react-dom'

Markdown = React.createFactory require './markdown'
MessageRich = React.createFactory require './message-rich'

{div, ul, li, hr} = React.DOM

PAGES = [
  {k: 'message rich', v: MessageRich}
  {k: 'markdown', v: Markdown}
]

Main = React.createClass

  getInitialState: ->
    page: PAGES[0].v

  onClick: (page) ->
    @setState
      page: page

  render: ->
    div className: 'app-container flex-vert',
      ul null, PAGES.map (page) =>
        li
          key: page.k
          onClick: (=> @onClick(page.v)),
          page.k
      hr()
      @state.page()

ReactDOM.render React.createElement(Main), document.querySelector('#app')
