module.exports =
  componentWillMount: ->
    @listeners = []

  subscribe: (recorder, fn) ->
    fn2 = => # prevent setState on unmounted component
      return unless @isMounted()
      fn()

    recorder.subscribe fn2
    @listeners.push
      remove: ->
        recorder.unsubscribe fn2

  componentWillUnmount: ->
    @listeners.forEach (listener) ->
      listener.remove()
    @listeners = []
