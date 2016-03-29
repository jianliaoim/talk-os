# object with data from: http://talk.ci/doc/restful/state.html
exports.check = (store, checkData) ->
  _teamId = checkData.get '_teamId'

  # unreadData: {
  #   _targetId: unreadNum
  # }
  unreadData = checkData.get 'data'

  if store.getIn ['notifications', _teamId]
    newStore = store
      .updateIn ['notifications', _teamId], (notifications) ->
        notifications.map (n) ->
          unread = unreadData.get(n.get('_targetId'))
          if unread?
            n.set('unreadNum', unread)
          else
            n.set('unreadNum', 0)

    teamUnread = newStore.getIn ['notifications', _teamId]
      .map (n) -> if n.get('isMute') then 0 else n.get('unreadNum')
      .reduce ((a, b) -> a + b), 0

    newStore.setIn ['teams', _teamId, 'unread'], teamUnread
  else
    store
