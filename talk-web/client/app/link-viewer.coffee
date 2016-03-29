React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

TopicName   = React.createFactory require '../app/topic-name'
StoryName = React.createFactory require '../app//story-name'
ContactName = React.createFactory require '../app/contact-name'
MessageToolbar = React.createFactory require '../app/message-toolbar'

div = React.createFactory 'div'
a = React.createFactory 'a'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'link-viewer'
  mixins: [PureRenderMixin]

  propTypes:
    message: T.instanceOf(Immutable.Map)
    onClose: T.func.isRequired

  onClose: ->
    @props.onClose()

  render: ->
    return if not @props.message.get('attachments').size

    target = @props.message.get('attachments').filter (attachment) ->
      attachment.get('category') is 'quote'
    quote = target.get(0).get('data')

    creator = @props.message.get('creator')

    pictureStyle =
      backgroundImage: "url(#{quote.get('thumbnailPicUrl')})"

    div className: 'link-viewer',
      div className: 'header',
        div className: 'category line',
          span className: 'icon icon-link'
          lang.getText('link')
        span className: 'button-close icon icon-remove', onClick: @onClose
      div className: 'body',
        div className: 'content text-overflow',
          div className: 'title', quote.get('title')
          div className: 'text', quote.get('text')
          a className: 'link', href: quote.get('redirectUrl'), target: '_blank',
            quote.get('redirectUrl')
        if quote.get('thumbnailPicUrl')?
          div className: 'picture', style: pictureStyle
      div className: 'footer',
        switch @props.message.get('type')
          when 'room'
            TopicName topic: @props.message.get('room')
          when 'dms'
            ContactName
              contact: @props.message.get('creator')
              _teamId: @props.message.get('_teamId')
          when 'story'
            story = @props.message.get('story')
            StoryName title: story.get('title'), category: story.get('category')
        MessageToolbar message: @props.message
