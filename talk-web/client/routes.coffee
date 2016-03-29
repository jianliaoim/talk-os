pathUtil = require 'router-view/lib/path'

module.exports = pathUtil.expandRoutes [
  # root router
  ['home', '/']

  # team router
  ['team',  '/team/:_teamId']
  ['overview',  '/team/:_teamId/overview']
  ['chat', '/team/:_teamId/chat/:_toId']
  ['room', '/team/:_teamId/room/:_roomId']
  ['tags', '/team/:_teamId/tags']
  ['story', '/team/:_teamId/story/:_storyId']
  ['favorites', '/team/:_teamId/favorites']
  ['collection', '/team/:_teamId/collection']
  ['create', '/team/:_teamId/create']
  ['integrations', '/team/:_teamId/integrations']
  ['mentions', '/team/:_teamId/mentions']

  # error handler of team
  ['team404', '/team/~']

  # profile router
  ['profile', '/profile']
  ['profile', '/setting/profile']

  # setting router
  ['setting-home', '/setting/~']
  ['setting-sync', '/setting/sync']
  ['setting-teams', '/setting/teams']
  ['setting-rookie', '/setting/rookie']
  ['setting-team-create', '/setting/team-create']
  ['setting-sync-teams',  '/setting/sync-teams']

  # error handler
  ['404', '~']
]
