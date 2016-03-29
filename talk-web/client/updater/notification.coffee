Immutable = require 'immutable'
refine = require '../util/refine'
reorder = require '../util/reorder'

###
 * Receive a semi-finished notification object,
 * insert for create a notification item in left sidebar.
 * But before insertion, should check upon two thing:
 * 1. if the notification is exist!!! cause we cannot determine
 *    which api (between create and read) comes faster
 * 2. if the notification is isHidden, and we are only update
 *    it's isHidden property.
 * WTF!
 *
 * @param {Immutable.Map} store
 * @param {Immutable.Map} notificationDatum
 *
 * @return {Immutable.Map} store
 *
 * TODO: TO RESOLVE THE ORDER AFTER (api notification.read).
###

sortNotifications = (store, _teamId) ->
  store.updateIn ['notifications', _teamId], (cursor) ->
    if cursor
      cursor
      .sortBy reorder.byUpdatedAt
      .sortBy reorder.isPinned
    else
      cursor

recountTeamUnread = (store, _teamId) ->
  notifications = store.getIn(['notifications', _teamId])
  if Immutable.List.isList(notifications)
    teamUnreadInNotifications = notifications.reduce (sum, n) ->
      unreadNum = if n.get('isMute') then 0 else n.get('unreadNum')
      sum + unreadNum
    , 0
    store = store.setIn ['teams', _teamId, 'unread'], teamUnreadInNotifications
  else
    store

exports.create = (store, notificationDatum) ->
  _notyId = notificationDatum.get '_id'
  _teamId = notificationDatum.get '_teamId'

  store =
    if store.hasIn [ 'notifications', _teamId ]
      store
      .updateIn [ 'notifications', _teamId ], (cursor) ->
        inCollection = (item) -> item.get('_id') is _notyId
        existIndex = cursor.findIndex inCollection

        if existIndex > -1
          cursor
          .update existIndex, (item) ->
            item.merge notificationDatum
        else
          cursor
          .push notificationDatum
    else
      data = Immutable.List [ notificationDatum ]
      store
      .setIn [ 'notifications', _teamId ], data

  sortNotifications(store, _teamId)

exports.read = (store, notificationsData) ->
  _teamId = notificationsData.get '_teamId'
  inTeam = _teamId is store.getIn(['device', '_teamId'])

  data = notificationsData.get('data')
    .filter refine.byNullTarget # 脏数据，旧数据中有可能没有target

  store =
    if data.size isnt 0
      if store.hasIn ['notifications', _teamId]
        store.updateIn ['notifications', _teamId], (cursor) ->
          data.forEach (dataItem) ->
            inCollection = (cursor) -> cursor.get('_id') is dataItem.get('_id')
            existIndex = cursor.findIndex inCollection
            if existIndex is -1
              cursor = cursor.push dataItem
            else
              cursor = cursor.update existIndex, (item) ->
                item.merge(dataItem)
          cursor
      else
        store.setIn ['notifications', _teamId], data
    else
      store

  if inTeam
    store = recountTeamUnread(store, _teamId)

  sortNotifications(store, _teamId)

exports.update = (store, newNotification) ->
  _id = newNotification.get '_id'
  _teamId = newNotification.get '_teamId'
  inTeam = _teamId is store.getIn(['device', '_teamId'])

  store = store
    .updateIn ['notifications', _teamId], (cursor) ->
      if cursor and Immutable.List.isList(cursor)
        index = cursor.findIndex (n) ->
          n.get('_id') is _id
        if index >= 0
          cursor.set(index, newNotification)
        else
          cursor.unshift(newNotification)
      else if inTeam
        Immutable.List [newNotification]
      else
        cursor
    .update 'teams', (cursor) ->
      if cursor.has _teamId
        cursor.updateIn [_teamId, 'unread'], (currentUnread) ->
          currentUnread or= 0
          if not newNotification.get('isMute')
            oldUnreadNum = newNotification.get('oldUnreadNum')
            unreadNum  = newNotification.get('unreadNum')
            # 本地发送的notification没有oldUnread, 所以直接从team.unread里减掉
            unreadDiff = if oldUnreadNum? then oldUnreadNum - unreadNum else unreadNum
            Math.max(currentUnread - unreadDiff, 0)
          else
            currentUnread
      else
        cursor

  if inTeam
    store = recountTeamUnread(store, _teamId)

  sortNotifications(store, _teamId)

exports.remove = (store, notificationsData) ->
  _id = notificationsData.get('_id')
  _teamId = notificationsData.get('_teamId')
  inTeam = _teamId is store.getIn(['device', '_teamId'])

  store = store
    .updateIn ['notifications', _teamId], (cursor) ->
      if cursor and Immutable.List.isList(cursor)
        cursor.filterNot (n) ->
          n.get('_id') is _id
      else
        cursor
    .updateIn ['teams', _teamId, 'unread'], (currentUnread) ->
      currentUnread or = 0
      Math.max(currentUnread - notificationsData.get('unreadNum'), 0)

  if inTeam
    store = recountTeamUnread(store, _teamId)

  sortNotifications(store, _teamId)

exports.preClearTeamUnread = (store, noty) ->
  store
    .updateIn ['teams', noty.get('_teamId'), 'unread'], (currentUnread) ->
      currentUnread or= 0
      Math.max(currentUnread - noty.get('unreadNum'), 0)

exports.postClearTeamUnread = (store, noty) ->
  store
    .updateIn ['teams', noty.get('_teamId'), 'unread'], (currentUnread) ->
      currentUnread + noty.get('unreadNum')
