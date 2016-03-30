React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'

selection     = require '../util/selection'
search        = require '../util/search'
emojisList    = require '../util/emojis-list'
dom           = require '../util/dom'
Util          = require '../util/util'
detect          = require '../util/detect'
lazyModules   = require '../util/lazy-modules'

lang        = require '../locales/lang'

LightPopover = React.createFactory require '../module/light-popover'
MentionMenu = React.createFactory require '../app/mention-menu'
EmojiMenu   = React.createFactory require '../app/emoji-menu'

module.exports =

  # methods need to implement
  # onTextKeydown: (event) ->
  # not complete...

  getInitialState: ->
    showMentionMenu: false
    showEmojiMenu: false
    members: @getMembers()
    contacts: @getContacts()
    suggestEmojis: []
    suggestMembers: Immutable.List()
    suggestContacts: Immutable.List()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        members: @getMembers()
        contacts: @getContacts()

  getMembers: ->
    query.membersBy(recorder.getState(), @props._roomId) or Immutable.List()

  getMentionBaseArea: ->
    if @_atSel?.node?
      selection.getCaretTopPoint @_atSel.node, @_atSel.offset
    else
      {}

  getEmojiBaseArea: ->
    if @_colonSel?.node?
      selection.getCaretTopPoint @_colonSel.node, @_colonSel.offset
    else
      {}

  trackRange: ->
    rangy = lazyModules.load('rangy')
    sel = rangy.getSelection()
    # returns
    node: sel.anchorNode
    offset: sel.anchorOffset

  mockRange: ->
    @_sel =
      node: @refs.text
      offset: 0
    @_atSel = {}
    @_colonSel = {}

  getTextFromStartToCaret: ->
    rangy = lazyModules.load('rangy')
    r = rangy.createRange()
    node = @refs.text
    r.setStart node, 0
    r2 = rangy.getSelection()
    r.setEnd r2.anchorNode, r2.anchorOffset
    r.toString()

  detectMention: ->
    return unless @props._roomId?
    text = @getTextFromStartToCaret()
    name = text.split('@')[1..].reverse()[0]
    if name is '' then @_atSel = @trackRange()
    @filterMembers name

  detectEmoji: ->
    text = @getTextFromStartToCaret()
    name = text.split(':')[1..].reverse()[0]
    if name is '' then @_colonSel = @trackRange()
    @filterEmojis name

  filterMembers: (name) ->
    all =
      _id: 'all'
      name: lang.getText('all-members')
      pinyins: if lang.getLang() is 'zh' then ['suoyou'] else ['all']
      avatarUrl: 'https://dn-talk.oss.aliyuncs.com/icons/all-members.png'
    _userId = query.userId(recorder.getState())

    members = @state.members
    .filter (member) ->
      member.get('_id') isnt _userId
    members = Immutable.fromJS([all]).concat members
    memberIds = members
    .map (member) -> member.get('_id')
    .toJS()

    contacts = @state.contacts
    .filter (member) ->
      member.get('_id') isnt _userId
    .filter (contact) ->
      # not memberIds.contains(contact.get('_id'))
      # switch to native method for performance
      memberIds.indexOf(contact.get('_id')) < 0
    suggestMembers = switch
      # caution: cannot change orders
      when name?.length > 0 then search.forMembers members, name, getAlias: @getContactAlias
      when name? then members
      else Immutable.List()
    suggestContacts = switch
      when name?.length > 0 then search.forMembers contacts, name, getAlias: @getContactAlias
      when name? then contacts
      else Immutable.List()
    @setState
      suggestMembers: suggestMembers
      suggestContacts: suggestContacts
      showMentionMenu: ((suggestMembers.size + suggestContacts.size) > 0)

  filterEmojis: (name) ->
    suggestEmojis = switch
      # caution sa above
      when name?.length then search.forEmojis emojisList, name
      when name? then emojisList
      else []
    @setState suggestEmojis: suggestEmojis, showEmojiMenu: (suggestEmojis.length > 0)

  # events

  onEmojiMenuClose: ->
    @setState showEmojiMenu: false

  onTextClick: ->
    @_sel = @trackRange()
    @detectMention()
    if detect.isIPad()
      setTimeout ->
        window.scrollTo 0, document.body.clientHeight
      , 100

  onTextKeyup: (event) ->
    @onTextChange()
    @onResize?()

  # this is a mocked event, called by program
  onTextChange: ->
    node = @refs.text
    @setState text: node.textContent
    @_sel = @trackRange()
    @detectMention()
    @detectEmoji()

  onMentionClick: ->
    selection.insertText @_sel.node, @_sel.offset, ' @'
    setTimeout =>
      @onTextChange()

  onMentionMenuClose: ->
    @setState showMentionMenu: false

  onMentionSelect: (data) ->
    @setState showMentionMenu: false
    prefs = query.contactPrefsBy(recorder.getState(), @props._teamId, data._id)
    name = prefs?.get('alias') or data.name

    mention = document.createElement 'mention'
    mention.setAttribute 'data-id', data._id
    mention.innerHTML = "@#{name}"

    selection.completeText @_atSel, @_sel, mention
    selection.moveForwardSpaceAfter(mention)

  # renderers

  renderMentionMenu: (hasMentionMenu) ->
    LightPopover
      name: 'mention'
      showClose: false
      baseArea: @getMentionBaseArea()
      onPopoverClose: @onMentionMenuClose
      positionAlgorithm: @positionMention
      show: hasMentionMenu
      MentionMenu
        onSelect: @onMentionSelect
        members: @state.suggestMembers
        contacts: @state.suggestContacts
        _teamId: @props._teamId

  renderEmojiMenu: (hasEmojiMenu) ->
    LightPopover
      name: 'emoji'
      showClose: false
      baseArea: if hasEmojiMenu then @getEmojiBaseArea() else {}
      onPopoverClose: @onEmojiMenuClose
      positionAlgorithm: @positionEmoji
      show: hasEmojiMenu
      EmojiMenu suggests: @state.suggestEmojis[...5], onSelect: @onEmojiMenuSelect
