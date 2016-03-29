React = require 'react'
Immutable = require 'immutable'

MessageRichFile = React.createFactory require '../../../client/module/message-rich-file'
MessageRichImage = React.createFactory require '../../../client/module/message-rich-image'
MessageRichQuote = React.createFactory require '../../../client/module/message-rich-quote'
MessageRichRTF = React.createFactory require '../../../client/module/message-rich-rtf'
MessageRichSpeech = React.createFactory require '../../../client/module/message-rich-speech'

fixtures = require './fixtures'

{div, hr} = React.DOM

DATA =
  file: MessageRichFile
  image: MessageRichImage
  quote: MessageRichQuote
  rtf: MessageRichRTF
  speech: MessageRichSpeech

module.exports = React.createClass

  renderFixtures: ->
    fixtures.map (attachment, i) =>
      div key: i, className: 'message-rich flex-horiz flex-vstart',
        div className: 'container flex-fill flex-vert',
          div className: 'body flex-vend flex-horiz',
            DATA[attachment.category]
              attachment:
                if attachment.category is 'image'
                  Immutable.fromJS(attachment)
                else
                  attachment
              source: attachment.data.source # speech

  render: ->
    div className: 'message-area flex-space',
      div className: 'scroller thin-scroll',
        div className: 'message-timeline',
          @renderFixtures()

