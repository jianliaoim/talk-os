# 以下链接应该跟后端对齐：
# https://jianliao.com/doc/index.html
module.exports =
  get:
    state:         '/state'
    messages:
      mentions:    '/messages/mentions'
      read:        '/messages'
      search:      '/messages/search'
      tags:        '/messages/tags'
    users:
      me:          '/users/me'
    teams:
      read:        '/teams'
      rooms:       '/teams/:id/rooms'
      members:     '/teams/:id/members'
      thirds:      '/teams/thirds'
    integrations:
      read:        '/integrations'
      checkrss:    '/integrations/checkrss'
    services:
      settings:    '/services/settings'
    rooms:
      read:        '/rooms' # unused
      readone:     '/rooms/:id'
    favorites:
      read:        '/favorites'
    tags:
      read:        '/tags'
    strikertoken:  '/strikertoken'
    stories:
      read:        '/stories'
      readone:     '/stories/:id'
    notifications:
      read:        '/notifications'
    discover:
      urlmeta:     '/discover/urlmeta'
    groups:
      read:        '/groups'
    invitations:
      read:        '/invitations'
    usages:
      read:        '/usages'
    activities:
      read: '/activities'

  post:
    messages:
      create:        '/messages'
      star:          '/messages/:id/star'
      unstar:        '/messages/:id/unstar'
      search:        '/messages/search'
      repost:        '/messages/:id/repost'
      receipt:       '/messages/:id/receipt'
    files:
      create:        '/files'
    users:
      subscribe:     '/users/subscribe'
      unsubscribe:   '/users/unsubscribe' # unused
      signout:       '/users/signout'
    teams:
      create:        '/teams'
      join:          '/teams/:id/join'
      leave:         '/teams/:id/leave'
      subscribe:     '/teams/:id/subscribe'
      unsubscribe:   '/teams/:id/unsubscribe'
      invite:        '/teams/:id/invite'
      batchinvite:   '/teams/:id/batchinvite'
      removemember:  '/teams/:id/removemember'
      setmemberrole: '/teams/:id/setmemberrole'
      refresh:       '/teams/:id/refresh'
      sync:          '/teams/sync'
      syncone:       '/teams/syncone'
    integrations:
      create:        '/integrations'
    rooms:
      create:        '/rooms'
      join:          '/rooms/:id/join'
      leave:         '/rooms/:id/leave'
      invite:        '/rooms/:id/invite'
      removemember:  '/rooms/:id/removemember'
      archive:       '/rooms/:id/archive'
      guest:         '/rooms/:id/guest'
    favorites:
      create:        '/favorites'
      search:        '/favorites/search'
    tags:
      create:        '/tags'
    stories:
      create: '/stories'
      leave: '/stories/:id/leave'
      join: '/stories/:id/join'
      search: '/stories/search'
    groups:
      create: '/groups'
    notifications:
      create: '/notifications'

  put:
    messages:
      update:     '/messages/:id'
    files:
      update:     '/files/:id'
    users:
      update:     '/users/:id'
    teams:
      update:     '/teams/:id'
      prefs:      '/teams/:id/prefs'
    integrations:
      update:     '/integrations/:id'
    preferences:
      update:     '/preferences'
    rooms:
      update:     '/rooms/:id'
      prefs:      '/rooms/:id/prefs'
    tags:
      update:     '/tags/:id'
    stories:
      update: '/stories/:id'
    notifications:
      update: '/notifications/:id'
    groups:
      update: '/groups/:id'

  delete:
    messages:
      remove:     '/messages/:id'
    integrations:
      remove:     '/integrations/:id'
    rooms:
      remove:     '/rooms/:id'
    favorites:
      remove:     '/favorites/:id'
    tags:
      remove:     '/tags/:id'
    invitations:
      remove:     '/invitations/:id'
    stories:
      remove: '/stories/:id'
    groups:
      remove: '/groups/:id'
    activities:
      remove: '/activities/:id'
