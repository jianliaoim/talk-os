# Schedule the tasks
{CronJob} = require 'cron'
requireDir = require 'require-dir'

# Initialize components and database connections
{logger, schedule} = require './components'
# Initialize services
require './service'
# Initialize observers
requireDir './observers'

# Config application
require './config/error'

# Scan the user scheduled jobs
jobTicker = new CronJob
  cronTime: '0 * * * * *'
  onTick: schedule.onTick

jobTicker.start()
