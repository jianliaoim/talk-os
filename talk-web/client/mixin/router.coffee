React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

T = React.PropTypes

module.exports =

  propTypes:
    router: T.instanceOf(Immutable.Map).isRequired

  # Extract channel id of router,
  # also you can pass specific property on parameter,
  # return channel id.
  #
  # @param { string } prop ( optional )
  #
  # @return string

  getChannelId: (prop) ->
    prop or= @extractType()
    @props.router.getIn [ 'data', prop ]

  # Determine the channel type of 'chat', 'room' or 'story',
  # return channel type.
  #
  # @return string

  getChannelType: ->
    routeName = @getRouteName()
    if @isChannelType routeName then routeName

  # Get the router name.
  #
  # @return string

  getRouteName: ->
    @props.router.get 'name'

  # Get the team id in router
  #
  # @return string

  getTeamId: ->
    @props.router.getIn [ 'data', '_teamId' ]

  # Determine if the params is active router
  #
  # @param { string } routerName
  #
  # @return boolean

  isActiveRoute: (routeName) ->
    @getRouteName() is routeName

  # Very function for channel type in 'chat', 'room' and 'story'
  #
  # @param { string } routerName
  #
  # @return boolean

  isChannelType: (routeName) ->
    routeName in [ 'chat', 'room', 'story' ]

  # Hack way to extract channel type and router name,
  # to specific what type of property to use.
  # return the target property for router.
  #
  # @return string

  extractType: ->
    switch @getRouteName()
      when 'chat' then '_toId'
      when 'room' then '_roomId'
      when 'story' then '_storyId'
