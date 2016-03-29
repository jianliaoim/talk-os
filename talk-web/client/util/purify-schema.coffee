
teamFilters = ['rooms', 'members', 'latestMessages', 'invitations', 'prefs']
topicFilters = ['members', 'team', 'prefs']

purifySchema = (target, filters) ->
  target.filterNot((value, key) -> key in filters)

exports.team = (team) ->
  purifySchema(team, teamFilters)

exports.topic = (topic) ->
  purifySchema(topic, topicFilters)
