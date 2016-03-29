# 成员之间的权限管理模块

React = require 'react'
assign = require 'object-assign'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

mixinSubscribe = require '../mixin/subscribe'

T = React.PropTypes

permission =
  member: 0b110
  admin:  0b100
  owner:  0b000

accessLevel =
  member: 0b001
  admin:  0b010
  owner:  0b100

hasPermission = (userRole, targetRole) ->
  allowedPermission = permission[targetRole]
  if not accessLevel[userRole]?
    throw Error "user role is unsupported: #{userRole}"
  if not allowedPermission?
    throw Error "target role is undefined: #{targetRole}"
  (accessLevel[userRole] & allowedPermission) > 0

create = (ComponentClass) ->

  React.createClass
    displayName: 'Permission Member ' + ComponentClass.displayName

    mixins: [mixinSubscribe]

    propTypes:
      _teamId: T.string.isRequired
      contact: T.instanceOf(Immutable.Map).isRequired # target contact

    getInitialState: ->
      user: @getUser()

    componentDidMount: ->
      @subscribe recorder, =>
        @setState
          user: @getUser()

    getUser: ->
      query.userFromContacts(recorder.getState(), @props._teamId)

    getUserRole: ->
      @state.user?.get('role') or 'member'

    getTargetMemberPermission: ->
      @props.contact.get('role') or 'member'

    render: ->
      userRole = @getUserRole()
      isAllowed = hasPermission userRole, @getTargetMemberPermission()

      if isAllowed
        props = assign {},
          hasPermission: isAllowed
          @props

        React.createElement ComponentClass, props
      else
        null

module.exports =
  create: create
  hasPermission: hasPermission
