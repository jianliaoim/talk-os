React = require 'react'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

div   = React.createFactory 'div'
span  = React.createFactory 'span'

Icon  = React.createFactory require '../module/icon'

T = React.PropTypes
cx = require 'classnames'

module.exports = React.createClass
  displayName: 'inte-adding'
  mixins: [PureRenderMixin]

  propTypes:
    inte: T.object.isRequired # immutable object
    onAddingClick: T.func.isRequired

  onAddingClick: (event) ->
    @props.onAddingClick(@props.inte.get('name'))

  render: ->
    inte = @props.inte
    language = lang.getLang()
    addText =
      if inte.get('name') is 'email'
        lang.getText('inte-email-details')
      else
        lang.getText('add')
    logoStyle =
      backgroundImage: "url(#{inte.get('iconUrl')})"

    # summary can accedently be a string
    summary = inte.get('summary').get(language)

    div className: "inte-adding is-#{inte.get('name')}",
      div className: 'logo', style: logoStyle
      div className: 'desc',
        div className: 'name', inte.get('title')
        div className: 'about muted', summary
      div className: 'button is-primary', onClick: @onAddingClick,
        Icon name: 'plus-circle', size: 18
        span className: 'text', addText
