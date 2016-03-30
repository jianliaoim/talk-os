React = require 'react'
recorder = require 'actions-recorder'
Immutable = require 'immutable'

query = require '../query'
search        = require '../util/search'
emojisList    = require '../util/emojis-list'
dom           = require '../util/dom'
Util          = require '../util/util'
detect          = require '../util/detect'
assemble = require '../util/assemble'

lang        = require '../locales/lang'

MentionMenu = React.createFactory require '../app/mention-menu'
TopicMenu   = React.createFactory require '../app/topic-menu'
EmojiMenu   = React.createFactory require '../app/emoji-menu'
CommandMenuClass = require '../app/command-menu'
CommandMenu = React.createFactory CommandMenuClass

module.exports =

  # methods need to implement
  # not complete...

  getInitialState: ->
    showMentionMenu: false
    showEmojiMenu: false
    showTopicMenu: false
    showCommandMenu: false
    members: @getMembers()
    contacts: @getAllContacts()
    topics: @getTopics()
    suggestEmojis: []
    suggestMembers: Immutable.List()
    suggestContacts: Immutable.List()
    suggestTopics: Immutable.List()
    suggestCommands: @getCommands()

  componentDidMount: ->
    @subscribe recorder, =>
      @setState
        members: @getMembers()
        contacts: @getAllContacts()
        topics: @getTopics()

  getMembers: ->
    members =
      switch @props._channelType
        when 'chat' then Immutable.List [query.contactsByOne recorder.getState(), @props._teamId, @props._channelId]
        when 'room' then query.membersBy(recorder.getState(), @props._teamId, @props._channelId)
        when 'story' then query.storiesByOne(recorder.getState(), @props._teamId, @props._channelId)?.get('members')

    members or Immutable.List()

  getAllContacts: ->
    if @props._channelType is 'chat'
      Immutable.List [query.contactsByOne recorder.getState(), @props._teamId, @props._channelId]
    else
      query.contactsBy(recorder.getState(), @props._teamId)

  getTopics: ->
    query.topicsBy(recorder.getState(), @props._teamId)

  getCommands: ->
    CommandMenuClass.commands

  getMentionDslTable: ->
    return [] if not @state
    allMembers = assemble.allMembers()
    @state.contacts
    .map (contact) =>
      prefs = query.contactPrefsBy(recorder.getState(), @props._teamId, contact.get('_id'))
      name = prefs?.get('alias') or contact.get('name')
      category: 'at'
      model: contact.get('_id')
      view: name
    .unshift Immutable.fromJS
      category: 'at'
      model: allMembers._id
      view: allMembers.name
    .toJS()

  getTopicDslTable: ->
    return [] if not @state
    @state.topics
      .map (topic) ->
        view = if topic.get('isGeneral') then lang.getText('room-general') else topic.get('topic')
        category: 'room'
        model: topic.get('_id')
        view: view
      .toJS()

  getDslTable: ->
    @getMentionDslTable().concat(@getTopicDslTable())

  filterMembers: (name) ->
    _userId = query.userId(recorder.getState())
    members = @state.members
    .filter (member) ->
      isSelf = member.get('_id') is _userId
      not isSelf
    if @props._channelType isnt 'chat'
      members = Immutable.fromJS([assemble.allMembers()]).concat members
    memberIds = members
    .map (member) -> member.get('_id')
    .toJS()

    contacts = @state.contacts
    .filter (contact) ->
      isSelf = contact.get('_id') is _userId
      # containsContact = memberIds.contains(contact.get('_id'))
      # switch to native method for performance
      containsContact = memberIds.indexOf(contact.get('_id')) >= 0
      not (isSelf or containsContact)

    suggestMembers = switch
      # caution: cannot change orders
      when name?.length > 0 then search.forMembers members, name, getAlias: @getContactAlias
      when name? then members
      else Immutable.List()
    suggestContacts = switch
      when name?.length > 0 then search.forMembers contacts, name, getAlias: @getContactAlias
      when name? then contacts
      else Immutable.List()

    suggestMembers: suggestMembers
    suggestContacts: suggestContacts
    showMentionMenu: ((suggestMembers.size + suggestContacts.size) > 0)

  filterEmojis: (name) ->
    suggestEmojis = switch
      when name?.length
        search.forEmojis emojisList, name
      when name?
        query.mostRecentEmojis(recorder.getState()).toJS()
      else
        []

    suggestEmojis: suggestEmojis
    showEmojiMenu: (suggestEmojis.length > 0)

  filterTopics: (name) ->
    suggestTopics = switch
      when name?.length
        @state.topics.filter (topic) ->
          search.forTopic topic, name
      when name?
        @state.topics
      else Immutable.List()

    suggestTopics: suggestTopics
    showTopicMenu: suggestTopics.size > 0

  filterCommands: (name) ->
    commands = @getCommands().filter (command) ->
      command.get('trigger').slice(1).indexOf(name) is 0

    suggestCommands: commands
    showCommandMenu: if __DEV__ then commands.size > 0 else false

  # renderers

  renderMentionMenu: (hasMentionMenu) ->
    return null if not hasMentionMenu
    MentionMenu
      onSelect: @onMentionSelect
      members: @state.suggestMembers
      contacts: @state.suggestContacts
      _teamId: @props._teamId

  renderTopicMenu: (hasTopicMenu) ->
    return null if not hasTopicMenu
    TopicMenu
      onSelect: @onTopicSelect
      topics: @state.suggestTopics
      _teamId: @props._teamId

  renderEmojiMenu: (hasEmojiMenu) ->
    return null if not hasEmojiMenu
    EmojiMenu
      suggests: @state.suggestEmojis[...5]
      onSelect: @onEmojiMenuSelect

  renderCommandMenu: (hasCommandMenu) ->
    return null if not hasCommandMenu
    CommandMenu
      commands: @state.suggestCommands
      onSelect: @onCommandMenuSelect
