React = require 'react'
lang = require '../locales/lang'

{ div, a } = React.DOM

url = require '../util/url'

module.exports = React.createClass
  displayName: 'talk-download'

  render: ->
    div className: 'talk-download flex-horiz',
      div className: 'client is-ios flex-static',
        div className: 'logo'
        a target: '_blank', href: url.iosAppUrl, 'iOS'
      div className: 'client is-android flex-static',
        div className: 'logo'
        a target: '_blank', href: url.androidAppUrl, 'Android'
      div className: 'client is-windows flex-static',
        div className: 'logo'
        div className: 'flex flex-around',
          a href: url.windows32AppUrl, 'x32'
          a href: url.windows64AppUrl, 'x64'
      div className: 'client is-osx flex-static',
        div className: 'logo'
        a href: url.macAppUrl, 'OS X'
      div className: 'client is-linux flex-static',
        div className: 'logo'
        div className: 'flex flex-around',
          a href: url.linux32AppUrl, 'x32'
          a href: url.linux64AppUrl, 'x64'
