React = require 'react'
classnames = require 'classnames'
Immutable = require 'immutable'
PureRenderMixin = require 'react-addons-pure-render-mixin'

lang = require '../locales/lang'

inteActions = require '../actions/inte'

api = require '../network/api'
TALK = require '../config'

mixinCreateTopic = require '../mixin/create-topic'
mixinInteHandler = require '../mixin/inte-handler'
mixinInteEvents  = require '../mixin/inte-events'

LightCheckbox = React.createFactory require '../module/light-checkbox'

isEqual = require 'lodash.isequal'

LiteDropdown = React.createFactory require 'react-lite-dropdown'

div     = React.createFactory 'div'

T = React.PropTypes
l = lang.getText

module.exports = React.createClass
  displayName: 'inte-teambition'
  mixins: [mixinCreateTopic, mixinInteHandler, mixinInteEvents, PureRenderMixin]

  propTypes:
    _teamId:  T.string.isRequired
    _roomId:  T.string.isRequired
    onPageBack:  T.func.isRequired
    inte:     T.object
    settings: T.object.isRequired # immutable object

  getInitialState: ->
    inte = @props.inte
    # see mixins for more state
    isLoading: false
    projects: Immutable.List()
    project: inte?.getIn(['project']) or null
    showMenu: false

  componentDidMount: ->
    @requestProjects()

  # methods

  isToSubmit: ->
    return false unless @state._roomId?
    return false unless @state.project?
    return false unless @state.events.length > 0
    return true

  getProjectId: ->
    @state.project?.get('_id') or null

  hasChanges: ->
    return false unless @props.inte?

    inte = @props.inte

    @props.settings.get('fields')
    .filter (field) -> not field.get('readonly')
    .some (field) =>
      not Immutable.is @state[field.get('key')], @props.inte.get(field.get('key'))

  requestProjects: ->
    @setState isLoading: true, projects: Immutable.List()

    fields = @props.settings.get('fields')
    projectField = fields.find (field) -> field.get('key') is 'project'
    projectsUrl = projectField.get('onLoad').get('get')

    # caution: projectUrl in settings is based on http://talk.bi
    if TALK.env is 'dev'
      projectsUrl = projectsUrl.replace 'http://talk.bi/v1', TALK.apiHost

    api.get(projectsUrl)
      .then (resp) =>
        @setState projects: Immutable.fromJS(resp), isLoading: false

  # events

  onMenuToggle: ->
    @setState showMenu: not @state.showMenu

  onProjectSelect: (project) ->
    @setState project: project

  # ajax events

  onCreate: ->
    unless @isToSubmit() then return false
    return false if @state.isSending

    selectedProject = @state.projects.find (project) =>
      project.get('_id') is @getProjectId()

    data =
      _teamId: @props._teamId
      _roomId: @state._roomId
      project: @state.project
      events: @state.events
      title: @state.title
      description: @state.description
      iconUrl: @state.iconUrl
      category: @props.settings.get('name')

    @setState isSending: true
    inteActions.inteCreate data,
      (resp) =>
        @setState isSending: false
        # why is this line?
        @props.onInteEdit Immutable.fromJS(resp)
        @onPageBack true
      (error) =>
        @setState isSending: false

  onUpdate: ->
    return false unless @hasChanges()
    return false if @state.isSending

    inte = @props.inte
    selectedProject = @state.projects.find (project) =>
      project.get('_id') is @getProjectId()

    data = {}
    data._roomId = @state._roomId if @state._roomId isnt inte.get('_roomId')
    if @getProjectId() isnt inte.getIn(['project', '_id'])
      data.project = @state.project.toJS()
    data.events = @state.events unless Immutable.is @state.events, inte.get('events')
    data.title = @state.title unless @state.title is inte.get('title')
    data.description = @state.description unless @state.description is inte.get('description')
    data.iconUrl = @state.iconUrl unless @state.iconUrl is inte.get('iconUrl')

    @setState isSending: true
    inteActions.inteUpdate @props.inte.get('_id'), data,
      (resp) =>
        @setState isSending: false
        @onPageBack()
      (error) =>
        @setState isSending: false

  # renderers

  renderItems: ->
    @state.projects.map (project) =>
      onClick = =>
        @onProjectSelect project
      div className: 'item', key: project.get('_id'), onClick: onClick,
        project.get('name')

  renderProjects: ->

    selectedProject = @state.projects.find (project) =>
      project.get('_id') is @getProjectId()

    LiteDropdown
      displayText: selectedProject?.get('name') or undefined
      defaultText: lang.getText('select-project')
      name: 'inte-teambition'
      show: @state.showMenu
      onToggle: @onMenuToggle
      @renderItems()

  renderProjectSelector: ->
    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('project-name')
        div className: 'about muted', lang.getText('on-select-project')
      div className: 'value',
        @renderProjects()

  render: ->

    div className: 'inte-teambition inte-board lm-content',
      @renderInteHeader()
      @renderTopicRow()
      @renderProjectSelector()
      @renderEvents()
      @renderInteTitle()
      @renderInteDesc()
      @renderInteIcon()
      if @props.inte?
        @renderInteModify()
      else
        @renderInteCreate()
      # modals
      @renderTopicCreate()
