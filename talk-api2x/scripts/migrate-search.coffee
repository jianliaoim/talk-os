Promise = require 'bluebird'
cluster = require 'cluster'
os = require 'os'
numCPUs = os.cpus().length
logger = require 'graceful-logger'

config = require 'config'
config.searchBulk = size: 999999999, delay: 999999999

if cluster.isMaster

  [0...numCPUs].forEach -> cluster.fork()

  cluster.on 'exit', (worker, code, signal) ->

    if code is 0
      logger.info "Worker #{worker.process.pid} exit without error"
    else
      logger.warn "Worker #{worker.process.pid} exit with error code #{code}"

else

  {limbo, logger, redis} = require '../server/components'

  {
    MessageModel
    FavoriteModel
    SearchMessageModel
    SearchFavoriteModel
  } = limbo.use 'talk'

  conditions = isSystem: false
  limit = 1000
  totalNum = 0

  _overrideModel = (SearchModel) ->
    SearchModel.flushAsync = Promise.promisify(SearchModel.flush)

  _overrideModel SearchMessageModel
  _overrideModel SearchFavoriteModel

  {worker} = cluster

  main = (type) ->

    switch type
      when 'message'
        DataModel = MessageModel
        SearchModel = SearchMessageModel
      when 'favorite'
        DataModel = FavoriteModel
        SearchModel = SearchFavoriteModel
      else return

    cursorKey = "search:#{type}:migrate:id:#{worker.id}"

    _getCursorId = -> redis.getAsync cursorKey

    _setCursorId = (_cursorId) ->
      redis.setexAsync cursorKey, 864000, _cursorId
      .then -> _cursorId

    _index = (_cursorId) ->
      conditions._id = $gt: _cursorId if _cursorId
      query = DataModel.find conditions
      .populate 'tags'
      .sort _id: 1
      .limit limit

      if _cursorId
        # 每次偏移量
        query = query.skip limit * (numCPUs - 1)
      else
        # 首次偏移量
        query = query.skip (worker.id - 1) * limit

      query.execAsync()
      .then (datas) ->
        return datas unless datas?.length
        for i, data of datas
          search = new SearchModel data.toObject()
          search.index {}, ->
        SearchModel.flushAsync().then -> datas

    _main = (_cursorId) ->
      logger.info "Start index #{type} from cursor id", _cursorId

      _index _cursorId

      .then (datas) ->
        return unless datas?.length
        _cursorId = datas[datas.length - 1]._id
        totalNum += datas.length
        logger.info "Complete index #{type} number", totalNum, "last cursor id", _cursorId
        _setCursorId _cursorId

      .then (_cursorId) ->
        return unless _cursorId
        _main _cursorId

    _getCursorId().then _main

  $message = main 'message'
  $favorite = main 'favorite'

  Promise.all [$message, $favorite]
  .then ->
    logger.info "Migrate search finish on #{worker.id}"
    process.exit 0
  .catch (err) ->
    logger.err err.stack
    process.exit 1
