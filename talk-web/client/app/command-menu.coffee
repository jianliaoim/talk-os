React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
Immutable = require 'immutable'
Q = require 'q'
recorder = require 'actions-recorder'
assign = require 'object-assign'

config = require '../config'

api = require '../network/api'

keyboard = require '../util/keyboard'
util = require '../util/util'

div  = React.createFactory 'div'
span = React.createFactory 'span'
img  = React.createFactory 'img'

T = React.PropTypes
cx = require 'classnames'

replaceAction = (triggerKey) ->
  (data) ->
    text = COMMANDS.getIn [triggerKey, 'text']
    trigger = COMMANDS.getIn [triggerKey, 'trigger']
    result = assign data,
      body: "#{text} #{data.body.substring(trigger.length)}"
    Q.when(result)

COMMANDS = Immutable.OrderedMap
  'debug': Immutable.fromJS {
    trigger: '/debug'
    text: ''
    isFake: true
    action: (data) ->
      router = recorder.getStore().get('router')
      lines = [
        'var | data'
        ' - | - '
        "version | #{config.version}"
        "router | `#{JSON.stringify(router.get('data').toJS())}`"
      ]
      result = assign data,
        body: lines.join('\n')
        displayType: 'markdown'
      Q.when(result)
  }
  'usage': Immutable.fromJS {
    trigger: '/usage'
    text: 'Check channel usage details'
    action: (data) ->
      Q(api.usages.read.get(queryParams: _teamId: data._teamId))
        .then (resp) ->
          lines = resp.map (data) ->
            "#{data.type} | #{data.amount} | #{data.maxAmount} |#{data.month}"
          head = [
            'type | amount | maxAmount | month'
            ' - | - | - | -'
          ]
          assign data,
            body: head.concat(lines).join('\n')
            displayType: 'markdown'
  }
  'flip': Immutable.fromJS {
    trigger: '/flip'
    text: '(╯°□°）╯︵ ┻━┻'
    action: replaceAction('flip')
  }
  'unflip': Immutable.fromJS {
    trigger: '/unflip'
    text: '┬─┬ノ( ゜-゜ノ)'
    action: replaceAction('unflip')
  }
  'poop': Immutable.fromJS {
    trigger: '/xiaowu'
    text: 'Surprise!'
    action: (data) ->
      result = assign data,
        body: '### {.ti .ti-poop}'
        displayType: 'markdown'
      Q.when(result)

  }

module.exports = React.createClass
  displayName: 'command-menu'
  mixins: [PureRenderMixin]

  propTypes:
    commands: T.instanceOf(Immutable.List).isRequired
    onSelect: T.func.isRequired

  getInitialState: ->
    index: 0

  statics:
    commands: COMMANDS.toList()

  componentDidMount: ->
    window.addEventListener 'keydown', @onWindowKeydown

  componentWillUnmount: ->
    window.removeEventListener 'keydown', @onWindowKeydown

  # methods

  moveSelectUp: ->
    if @props.commands.size < 2 then return
    if @state.index is 0
    then @setState index: @props.commands.size - 1
    else @setState index: (@state.index - 1)

  moveSelectDown: ->
    if @props.commands.size < 2 then return
    if (@state.index + 1) is @props.commands.size
    then @setState index: 0
    else @setState index: (@state.index + 1)

  selectCurrent: ->
    command = @props.commands.get(@state.index)
    @props.onSelect command

  # event handlers

  onItemClick: (command) ->
    @props.onSelect command

  onWindowKeydown: (event) ->
    switch event.keyCode
      when keyboard.up then @moveSelectUp()
      when keyboard.down then @moveSelectDown()
      when keyboard.enter then @selectCurrent()
      when keyboard.tab then @selectCurrent()

  render: ->
    div className: 'menu',
      @props.commands.map (command, index) =>
        onClick = =>
          @onItemClick command
        className = cx 'flex', 'item',
          'is-active': @state.index is index

        div className: className, onClick: onClick, key: index,
          span className: 'flex-fill', command.get('trigger')
          span className: 'text', command.get('text')
