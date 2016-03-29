
React = require 'react'
Immutable = require 'immutable'
LiteLoadingCircle = React.createFactory require('react-lite-misc').LoadingCircle

colors = require '../util/colors'

{div, span} = React.DOM
T = React.PropTypes

module.exports = React.createClass
  displayName: 'team-wireframe'

  propTypes:
    team: T.instanceOf(Immutable.Map).isRequired

  render: ->
    div className: 'team-wireframe',
      div className: 'icon', @props.team.get('name')[0]
      div className: 'name', @props.team.get('name')

      LiteLoadingCircle()
