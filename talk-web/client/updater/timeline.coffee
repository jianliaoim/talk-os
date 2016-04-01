moment = require 'moment'
Immutable = require 'immutable'

exports.init = (store, data) ->
  _teamId = data.get '_teamId'
  createdAt = data.get 'createdAt'
  currentAt = data.get 'currentAt'

  diffYears = currentAt.getYear() - createdAt.getYear()
  diffMonths = currentAt.getMonth() - createdAt.getMonth()

  count = diffYears * 12 + diffMonths
  results = Immutable.Repeat(createdAt, count + 1)
    .toList()
    .map (v, k) ->
      moment(v).add(k, 'months')
    .groupBy (v) ->
      v.year()
    .map (v) ->
      v.map (v) ->
        Immutable.Map
          value: v.endOf('month').valueOf()
          display: v.format('MMM')
      .reverse()
    .reverse()
    .reduce (r, v, k) ->
      r.push Immutable.Map
        display: moment().year(k).format('Y')
        months: v
    , Immutable.List()

  store.setIn ['timelineList', _teamId], results
