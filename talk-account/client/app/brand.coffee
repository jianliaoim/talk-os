
React = require 'react'
Immutable = require 'immutable'

{div} = React.DOM

module.exports = React.createClass
  displayName: 'app-brand'

  propTypes:
    language: React.PropTypes.string.isRequired

  render: ->

    div className: "app-brand is-#{@props.language}"
