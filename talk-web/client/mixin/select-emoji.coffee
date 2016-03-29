React = require 'react'

LitePopover = React.createFactory require 'react-lite-layered/lib/popover'

EmojiTable = React.createFactory require '../app/emoji-table'

module.exports =

  # methods need to implement
  # getEmojiTableBaseArea: ->
  # onEmojiSelect: (data) ->

  getInitialState: ->
    showEmojiTable: false

  positionEmojiTable: (baseArea) ->
    bottom: "#{window.innerHeight - baseArea.top}px"
    left: "#{baseArea.left}px"

  onEmojiTableClick: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @setState showEmojiTable: (not @state.showEmojiTable)

  onEmojiTableClose: ->
    @setState showEmojiTable: false

  renderEmojiTable: ->
    LitePopover
      name: 'emoji-table'
      showClose: false
      baseArea: if @state.showEmojiTable then @getEmojiTableBaseArea() else {}
      onPopoverClose: @onEmojiTableClose
      positionAlgorithm: @positionEmojiTable
      show: @state.showEmojiTable
      EmojiTable onSelect: @onEmojiSelect
