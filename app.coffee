express = require 'express'
tracker_ = require './lib/tracker'
storage_ = require './lib/storage'
config = require './lib/config'
_ = require 'underscore'



storage = new storage_.Storage()
tracker = new tracker_.Tracker(storage)

app = express()
app.use express.logger()
app.use express.errorHandler()
app.use express.static __dirname + '/static'
app.disable "x-powered-by"

app.get '/stats', (req, res) ->
  storage.generateStatistics (stats) ->
    stats.queries = _.values tracker.queries
    res.jsonp 200, stats

app.listen config.port
