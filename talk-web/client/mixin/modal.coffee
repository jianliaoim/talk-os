module.exports =

  getInitialState: ->
    modalType: ''
    showModal: false

  onCloseModal: ->
    @setState
      modalType: ''
      showModal: false

  onOpenModal: (modalType = '') ->
    @setState
      modalType: modalType
      showModal: true
