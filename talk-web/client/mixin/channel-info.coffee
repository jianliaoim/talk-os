# This mixin mean to distribute infomation from channel,
# avatar url, name, etc.
# Also make extract process more readable,
# cause channel property is such a big diffrence.

cx = require 'classnames'
React = require 'react'
typeOf = require 'type-of'
Immutable = require 'immutable'

UserAlias = React.createFactory require '../app/user-alias'

lang = require '../locales/lang'

colors = require '../util/colors'

T = React.PropTypes

module.exports =

  propTypes:
    _channelType: T.string.isRequired
    member: T.instanceOf(Immutable.Map)
    channel: T.instanceOf(Immutable.Map).isRequired

  isChannel: (target) ->
    @props._channelType is target

  # Detect if show the more button, or the user is a quited member.
  #
  # @return boolean

  isQuitted: ->
    if not @isChannel 'chat'
      return (@props.channel.getIn [ 'isQuit' ]) or false
    false

  # Detect if channel charactor is Talk AI.
  #
  # @return boolean

  isTalkAI: ->
    if @props._channelType is 'chat'
      return (@props.channel.getIn [ 'service' ]) is 'talkai'
    false

  # NOT IMPLEMENT YET!
  # Extract and generate avatar for channel
  # return className, style, text.
  #
  # @return object

  extractAvatar: ->

  # Extract member count of the channel.
  #
  # @return number

  extractMember: ->
    switch @props._channelType
      when 'room' then @props.members
      when 'story' then (@props.channel.getIn [ 'members' ])

  # Extract channel title from @props.channel with type of @props._channelType,
  # diffrent type of channel access diffrent data property,
  # return the channel title.
  #
  # @return string

  extractTitle: ->
    switch @props._channelType
      when 'chat'
        UserAlias _teamId: @props._teamId, _userId: @props.channel.get('_id'), defaultName: @props.channel.get('name')
      when 'room'
        return lang.getText 'room-general' if @props.channel.get 'isGeneral'
        @props.channel.get 'topic'
      when 'story'
        return @props.channel.getIn [ 'data', 'fileName' ] if @props.channel.get('category') is 'file'
        @props.channel.getIn [ 'data', 'title' ]
      else ''

  # Extract channel introduction.
  #
  # @return string

  extractText: ->
    switch @props._channelType
      when 'chat'
        return lang.getText 'contact-quitted' if @props.channel.get 'isQuit'
        lang.getText @props.channel.get 'role'
      when 'story' then @props.channel.getIn [ 'data', 'text' ]
      else ''

  # Very function to extract property from story data.
  #
  # @param { array } props
  #
  # @return string

  extractFromStory: (props) ->
    if typeOf(props) is 'array'
      if @props._channelType is 'story'
        @props.channel.getIn props
      else
        console.warn 'Now you are extract prop from other type of stroy data.'
    else
      console.error 'Parameter (props) should be Array type.'
