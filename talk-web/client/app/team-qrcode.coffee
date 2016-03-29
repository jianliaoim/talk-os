utf8 = require 'utf8'
React = require 'react'
base64 = require 'base-64'
qrcode = require 'qrcode-generator'
Immutable = require 'immutable'

lang = require '../locales/lang'

{ p, div } = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-qrcode'

  propTypes:
    team: T.instanceOf(Immutable.Map).isRequired

  makeQRCode: ->
    data = base64.encode utf8.encode JSON.stringify
      _id: @props.team.get 'id'
      name: @props.team.get 'name'
      color: @props.team.get 'color'
      signCode: @props.team.get 'signCode'

    qr = qrcode 8, 'M'

    qr.addData data
    qr.make()
    qr.createImgTag(4, 0)

  render: ->
    div className: 'team-qrcode',
      div dangerouslySetInnerHTML: __html: @makeQRCode()
      p {}, lang.getText('scan-qrcode-to-join').replace '%s', @props.team.get 'name'
