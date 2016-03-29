React = require 'react'
cx = require 'classnames'
Immutable = require 'immutable'

orders = require '../util/orders'

lang = require '../locales/lang'

Permission = require '../module/permission'

ContactItem = React.createFactory require './contact-item'

{ div, span, button } = React.DOM

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'group-details'

  propTypes:
    _teamId: T.string.isRequired
    group: T.instanceOf(Immutable.Map).isRequired
    contacts: T.instanceOf(Immutable.List).isRequired

  render: ->
    div className: 'group-details flex-vert',
      div className: 'list thin-scroll',
        @props.group.get('_memberIds').map (_memberId) =>
          member = @props.contacts.find (contact) ->
            contact.get('_id') is _memberId

          ContactItem
            key: _memberId
            _teamId: @props._teamId
            contact: member
            showAction: false
