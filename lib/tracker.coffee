tabletop = require 'tabletop'
_ = require 'underscore'
config = require './config'
twitter = require './twitter'


class TrackerManager
  
  constructor: () ->
    @trackers = {}
    @loadData()
    self = @
    cb = () ->
      self.loadData()
    setInterval cb, 1500

  loadData: () ->
    cur = @
    tabletop.Tabletop.init
      key: config.gdoc_key
      simpleSheet: true
      callback: (d,h) ->
        cur.handleData d, h
    
  handleData: (data, tabletop) ->
    queries = _.pluck data, 'query'
    for [query, tracker] in _.pairs @trackers
      if -1 is queries.indexOf(query)
        @trackers[query].quit()
        delete @trackers[query]
    for spec in data
      if not @trackers[spec.query]?
        @trackers[spec.query] = new Tracker spec.bucket, spec.query
    

class Tracker

  constructor: (@bucket, @query) ->
    console.log "Tracking: " + @query
    @track()
  
  track: () ->
    self = @
    feed =
      language: 'de'
      track: @query
    twitter.client.stream 'statuses/filter', feed, (stream) ->
      self.stream = stream
      stream.on 'data', (data) ->
        self.handleData data
      stream.on 'error', (data) ->
        console.error data

  handleData: (data) ->
    console.log data.text
  
  quit: ->
    console.log "Terminating: " + @query
    if @stream?
      @stream.destroy()


exports.TrackerManager = TrackerManager
