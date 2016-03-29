React = require 'react'
assign = require 'object-assign'
recorder = require 'actions-recorder'

query = require '../query'

mixinSubscribe = require '../mixin/subscribe'

{ noscript } = React.DOM
T = React.PropTypes

permission =
  member: 0b111
  admin:  0b110
  owner:  0b100

# 现在程序里功能上admin和owner没有区别
accessLevel =
  member: 0b001
  admin:  0b100
  owner:  0b100

hasPermission = (userRole, allowedPermission) ->
  if not accessLevel[userRole]?
    throw Error "user role is unsupported: #{userRole}"
  if not allowedPermission?
    throw Error "permission is undefined: #{allowedPermission}"
  (accessLevel[userRole] & allowedPermission) > 0

componentMode =
  hide: 'hide' # 权限不够的话不显示
  propogate: 'propogate' # 权限不同会改变样式


# This create func require _teamId
# to define if the user has right permission,
# but maybe we could use other way to make this work.
# just a note.
#

create = (ComponentClass, allowedPermission, mode = componentMode.hide) ->

  React.createClass
    displayName: 'Permission ' + ComponentClass.displayName

    mixins: [mixinSubscribe]

    propTypes:
      _teamId: T.string.isRequired
      _creatorId: T.string

    getInitialState: ->
      user: @getUser()

    componentDidMount: ->
      @subscribe recorder, =>
        @setState
          user: @getUser()

    isCreator: ->
      @state.user?.get('_id') is @props._creatorId

    getUser: ->
      query.userFromContacts(recorder.getState(), @props._teamId)

    getUserRole: ->
      @state.user?.get('role') or 'member'

    render: ->
      userRole = @getUserRole()
      isAllowed = hasPermission userRole, allowedPermission
      isCreator = @isCreator()

      componentHasPermission = isCreator or isAllowed

      if componentHasPermission or mode is componentMode.propogate
        props = assign {},
          role: if isCreator then 'creator' else userRole
          hasPermission: componentHasPermission
          @props

        React.createElement ComponentClass, props
      else
        noscript()

module.exports =
  mode: componentMode
  admin: permission.admin
  owner: permission.owner
  create: create
  member: permission.member
  hasPermission: hasPermission
  superRole: [ 'admin', 'creator', 'owner' ]
