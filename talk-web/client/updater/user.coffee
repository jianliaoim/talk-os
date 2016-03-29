
exports.me = (store, userData) ->

  if userData?
    store
    .set 'user', userData
    .set 'prefs', userData.get('preference')
  else
    store.set 'user', null

# user object: http://talk.ci/doc/restful/user.update.html
exports.update = (store, contactData) ->
  _contactId = contactData.get('_id')

  store
  .update 'user', (user) ->
    if _contactId is user.get('_id')
      user.merge contactData
    else user
  .update 'contacts', (cursor) ->
    cursor.map (contacts) ->
      contacts.map (contact) ->
        if contact.get('_id') is _contactId
          contactData
        else contact

  .update 'members', (cursor) ->
    cursor.map (innerCursor) ->
      innerCursor.map (members) ->
        members.map (member) ->
          if member.get('_id') is _contactId
            contactData
          else member
