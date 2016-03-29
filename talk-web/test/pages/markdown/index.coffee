React = require 'react'
Immutable = require 'immutable'
Markdown = React.createFactory require '../../../client/module/markdown'

emojisCategory = require '../../../client/util/emojis-category'

fixtures = require './fixtures'

{div} = React.DOM

module.exports = React.createClass
  render: ->
    div className: 'message-area', style: {position: 'static'},
      div className: 'scroller thin-scroll',
        div className: 'message-timeline',
          div className: 'message-rich',
            Immutable.fromJS(emojisCategory)
              .map (emojis, category) ->
                text = emojis.map((e) -> ":#{e}:").join(' ')
                div key: category,
                  div null, category
                  Markdown value: text
              .toList()
          fixtures.map (text, i) ->
            div key: i, className: 'message-rich',
              Markdown
                value: text
