# This mixin functions mean to shorten popouts relative code,
# including three state:
#   * @state { DOMElement } popoutsEl : DOM Element to calculate popouts base area.
#   * @state { string } popoutsType: Distinguish different type of popouts.
#   * @state { boolean } showPopouts: Show or hidden boolean property for popouts.

module.exports =

  getInitialState: ->
    popoutsEl: null
    popoutsType: ''
    showPopouts: false

  getPopoutsBaseArea: ->
    @state.popoutsEl?.getBoundingClientRect() or {}

  onClosePopouts: ->
    @setState
      popoutsEl: null
      popoutsType: ''
      showPopouts: false

  onOpenPopouts: (popoutsEl = null, popoutsType = '') ->
    @setState
      popoutsEl: popoutsEl
      popoutsType: popoutsType
      showPopouts: true

  onTogglePopouts: (popoutsEl = null, popoutsType = '') ->
    return @onClosePopouts() if (@state.popoutsType is popoutsType) and @state.showPopouts
    @onOpenPopouts popoutsEl, popoutsType
