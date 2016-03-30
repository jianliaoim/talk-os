React = require 'react'
classnames = require 'classnames'
uploadUtil  = require '../util/upload'

lang = require '../locales/lang'
config = require '../config'
handlers = require '../handlers'

Icon  = React.createFactory require '../module/icon'
CopyArea = React.createFactory require('react-lite-misc').Copyarea

fieldsReader = require '../util/fields-reader'

inteActions = require '../actions/inte'

div     = React.createFactory 'div'
span    = React.createFactory 'span'
button  = React.createFactory 'button'
input   = React.createFactory 'input'
a       = React.createFactory 'a'

l = lang.getText

module.exports =

  getInitialState: ->
    settings = @props.settings
    language = lang.getLang()
    inte = @props.inte

    # returns an object
    isSending: false
    showGuide: not @props.inte?
    # these fields are corresponding to the settings
    _roomId:      inte?.get('_roomId')     or @props._roomId
    title:        inte?.get('title')       or settings.get('title')
    description:  inte?.get('description')
    iconUrl:      inte?.get('iconUrl')     or settings.get('iconUrl')

  # methods

  # events

  onGuideToggle: ->
    @setState showGuide: (not @state.showGuide)

  onPageBack: ->
    @props.onPageBack(@props.inte?)

  onTitleChange: (event) -> @setState title: event.target.value
  onDescChange: (event) -> @setState description: event.target.value

  onUploaderComplete: ({fileData}) ->
    @setState iconUrl: fileData.thumbnailUrl

  onFileClick: (event) ->
    uploadUtil.handleClick
      accept: ".jpg,.jpeg,.bmp,.png"
      onSuccess: @onUploaderComplete
      onError: handlers.fileError

  # events

  onRemove: ->
    return false if @state.isSending
    @setState isSending: true
    inteActions.inteRemove @props.inte,
      (resp) =>
        @setState isSending: false
        @onPageBack()
      (error) =>
        @setState isSending: false

  # renderers

  renderInteHeader: ->
    language = lang.getLang()
    settings = @props.settings

    iconStyle =
      backgroundImage: "url(#{settings.get('iconUrl')})"
    html =
      __html: settings.get('description').get(language)

    div className: 'header',
      div className: 'icon-url', style: iconStyle
      div className: 'inte-title',
        span className: 'name', settings.get('title')
        span className: 'muted', dangerouslySetInnerHTML: html
      div className: 'return button is-link', onClick: @onPageBack,
        Icon name: 'arrow-left-circle-solid', size: 18
        span className: 'text', l('return-integrations-list')

  renderInteGuide: ->
    language = lang.getLang()
    settings = @props.settings

    inteHelpMd = settings.get('manual').get(language)
    inteHelpMd = inteHelpMd.replace(/LOCALE_LINK/g, @state.webhookUrl)

    iconClass = classnames 'ti',
      'ti-chevron-down': not @state.showGuide,
      'ti-chevron-up': @state.showGuide

    div className: 'guide-area',
      span className: 'guide-toggler', onClick: @onGuideToggle,
        span className: 'inte-guide', l('inte-guide')
        span className: iconClass
      if @state.showGuide
        div className: 'inte-guide-content', dangerouslySetInnerHTML: { __html: inteHelpMd }

  renderInteUrl: ->
    language = lang.getLang()
    fields = @props.settings.get('fields').toJS()
    field = fieldsReader.getField fields, 'url'

    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', 'URL'
        div className: 'about muted', field.description[language]
      div className: 'line value',
        input type: 'text', className: 'form-control', valueLink: @linkState('url')

  renderWebhookUrl: (webhookUrl) ->
    language = lang.getLang()
    fields = @props.settings.get('fields').toJS()
    field = fieldsReader.getField fields, 'webhookUrl'

    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', l('generate-webhook')
        div className: 'about muted', field.description[language]
      div className: 'value',
        CopyArea text: webhookUrl

  renderInteToken: ->
    language = lang.getLang()
    fields = @props.settings.get('fields').toJS()
    field = fieldsReader.getField fields, 'token'

    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', l('token')
        div className: 'about muted', (field.description?[language] or '')
      div className: 'value',
        input type: 'text', className: 'form-control', valueLink: @linkState('token'), placeholder: l('token-for-validation')

  renderInteModify: ->
    disabled = (not @hasChanges()) or @state.isSending
    buttonClass = classnames 'button', 'is-primary',
      'is-disabled': disabled

    div className: 'table-pair is-control',
      div className: 'attr'
      div className: 'line value',
        button className: buttonClass, disabled: disabled, onClick: @onUpdate, l('save-changes')
        button className: 'button is-danger', onClick: @onRemove, l('remove-integration')

  renderInteCreate: ->
    disabled = (not @isToSubmit()) or @state.isSending
    buttonClass = classnames 'button is-primary',
      'is-disabled': disabled

    div className: 'table-pair is-control',
      div className: 'attr'
      div className: 'value',
        button className: buttonClass, disabled: disabled, onClick: @onCreate, l('confirm-adding')

  renderInteTitle: ->
    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('custom-name')
        div className: 'about muted', lang.getText('about-custom-name')
      div className: 'value',
        input
          type: 'text', className: 'form-control', value: @state.title
          onChange: @onTitleChange, placeholder: lang.getText('optional')

  renderInteDesc: ->
    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('custom-description')
        div className: 'about muted', lang.getText('about-custom-description')
      div className: 'value',
        input
          type: 'text', className: 'form-control', value: @state.description
          onChange: @onDescChange, placeholder: lang.getText('optional')

  renderInteIcon: ->
    iconStyle = {}
    if @state.iconUrl?
      iconStyle.backgroundImage = "url(#{@state.iconUrl})"

    div className: 'table-pair',
      div className: 'attr',
        div className: 'title', lang.getText('custom-icon-url')
        div className: 'about muted', lang.getText('about-custom-icon-url')
      div className: 'value',
        div className: 'icon-url', style: iconStyle
        a className: 'upload btn-url', onClick: @onFileClick, lang.getText('upload')
