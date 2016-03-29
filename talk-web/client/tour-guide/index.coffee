# http://github.hubspot.com/shepherd/

Shepherd = require 'tether-shepherd'
prefActions = require '../actions/prefs'
lang = require '../locales/lang'

l = (key) ->
  lang.getText('tour-guide-' + key)

getLocale = (key) ->
  lang.getText('tour-guide-' + key)

KEY = 'v3-0-0-start-guide'
tour = null

updateWebData = (webData) ->
  webData[KEY] = (new Date).valueOf()
  prefActions.prefsUpdate({webData})

initTour = (webData) ->

  tour = new Shepherd.Tour
    defaults:
      classes: 'shepherd-theme-default'
      showCancelLink: true

  tour.on 'start', ->
    shepherdBackdrop = document.createElement 'div'
    shepherdBackdrop.className = 'shepherd-backdrop'
    document.body.appendChild(shepherdBackdrop)

  tour.on 'complete', ->
    shepherdBackdrop = document.querySelector('.shepherd-backdrop')
    document.body.removeChild(shepherdBackdrop)
    updateWebData(webData)

  tour.on 'cancel', ->
    shepherdBackdrop = document.querySelector('.shepherd-backdrop')
    document.body.removeChild(shepherdBackdrop)
    updateWebData(webData)

  tour.addStep 'start',
    text: """
      <div class=\"center\">
        <img class=\"image\" src=\"#{ require '../images/tour/3.0-guide@2x.jpg' }\" />
        <p class=\"title\">#{ getLocale 'start-title' }</p>
      </div>
    """
    showCancelLink: false
    buttons: [
      {
        text: getLocale 'cancel-button'
        action: tour.cancel
        classes: 'cancel'
      }
      {
        text: getLocale 'start-text'
        action: tour.next
        classes: 'start'
      }
    ]

  tour.addStep 'team-sidebar',
    text: """
      <div class=\"left\">
        <img class=\"image\" src=\"#{ require '../images/tour/inbox-guide@2x.png' }\" />
      </div>
      <div class=\"right\">
        <p class=\"title\">#{ getLocale 'team-sidebar-title' }</p>
        <p class=\"text\">#{ getLocale 'team-sidebar-text' }</p>
      </div>
    """
    attachTo: '.team-sidebar right'
    showCancelLink: false
    buttons: [
      {
        text: '<span class="active"></span><span></span><span></span>'
        classes: 'step'
      }
      {
        text: getLocale 'next-button'
        action: tour.next
        classes: 'next'
      }
    ]

  tour.addStep 'message-editor',
    text: """
      <div class=\"left\">
        <img class=\"image\" src=\"#{ require '../images/tour/message-guide@2x.png' }\" />
      </div>
      <div class=\"right\">
        <p class=\"title\">#{ getLocale 'message-editor-title' }</p>
        <p class=\"text\">#{ getLocale 'message-editor-text' }</p>
      </div>
    """
    attachTo: '.message-editor top'
    showCancelLink: false
    buttons: [
      {
        text: '<span></span><span class="active"></span><span></span>'
        classes: 'step'
      }
      {
        text: getLocale 'next-button'
        action: tour.next
        classes: 'next'
      }
    ]

  tour.addStep 'launch-button',
    text: """
      <div class=\"left\">
        <img class=\"image\" src=\"#{ require '../images/tour/launch-guide@2x.png' }\" />
      </div>
      <div class=\"right\">
        <p class=\"title\">#{ getLocale 'launch-button-title' }</p>
        <p class=\"text\">#{ getLocale 'launch-button-text' }</p>
      </div>
    """
    attachTo: '.btn-launch bottom'
    showCancelLink: false
    buttons: [
      {
        text: '<span></span><span></span><span class="active"></span>'
        classes: 'step'
      }
      {
        text: l('complete-button')
        action: tour.complete
        classes: 'next'
      }
    ]

  tour

module.exports.start = (webData = {}) ->
  if not webData[KEY]
    initTour(webData).start()
