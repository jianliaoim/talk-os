Promise = require 'bluebird'
Err = require 'err1st'
shortid = require 'shortid'

redis = require './redis'
logger = require './logger'

Promise.promisifyAll redis

schedule =

  addTask: (task) ->
    Promise.resolve().then ->
      task.executeAt = new Date(task.executeAt).getTime()

      throw new Err('PARAMS_INVALID', 'Task.executeAt') if isNaN(task.executeAt)

      task.id or= "#{task.action}#{shortid()}"

      logger.info 'Add task', task.id

      redis.multi()
      .hset 'scheduler:tasks', task.id, JSON.stringify(task)
      .zadd 'scheduler:taskidlist', task.executeAt, task.id
      .execAsync()

  removeTask: (taskId) ->
    Promise.resolve().then ->
      logger.info 'Remove task', taskId

      redis.multi()
      .hdel 'scheduler:tasks', taskId
      .zrem 'scheduler:taskidlist', taskId
      .execAsync()

  onTick: ->
    now = Date.now()
    redis.multi()
    .zrangebyscore "scheduler:taskidlist", 0, now
    .zremrangebyscore "scheduler:taskidlist", 0, now
    .exec (err, [taskIds]) -> taskIds?.forEach schedule.runTask

  ###*
   * Execute the task
   * @param  {String} taskId [description]
   * @return {Promise}        [description]
   * @todo Retry several times when the job failed
  ###
  runTask: (taskId) ->
    jobs = require '../jobs'

    task = null

    redis.hgetAsync 'scheduler:tasks', taskId

    .then (_task) ->

      task = _task

      throw new Error("job missing: can not find the job by id #{taskId}") unless task

      task = JSON.parse task

      {id, action, args, executeAt} = task
      args or= []
      delay = executeAt - Date.now()

      throw new Error("Job error [#{id}]: no such job") unless typeof jobs[action] is 'function'

      _execute = ->
        logger.info "Job start [#{id}]"
        jobs[action].apply jobs, args

      if delay > 0
        Promise.delay(delay).then _execute
      else
        _execute()

    .then -> logger.info "job finish [#{task.id}]"

    .catch (err) -> logger.warn "#{err.stack}"

    .then -> redis.hdelAsync 'scheduler:tasks', taskId

module.exports = schedule
