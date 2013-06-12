express = require 'express'
_ = require 'underscore'

exports.createApp = (storage) ->
    app = express()
    app.use express.logger()
    app.use express.errorHandler()
    app.use express.static __dirname + '/static'
    app.disable "x-powered-by"

    app.get '/stats', (req, res) ->
      storage.generateStatistics (stats) ->
        stats.queries = _.values tracker.queries
        stats.follow = tracker.compose 'follow'
        stats.track = tracker.compose 'track'
        res.jsonp 200, stats

    app.get '/latest', (req, res) ->
      storage.getLatest (statuses) ->
        res.jsonp 200, statuses
