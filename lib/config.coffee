tabletop = require 'tabletop'
_ = require 'underscore'
env = require './env'
twitter = require './twitter'


class Tracker

  constructor: (@storage) ->
    self = @

  track: () ->
    self = @
    @loadQueries()
    cb = () ->
      self.loadQueries()
    setInterval cb, 1000 * 60 * 60

  loadQueries: () ->
    cur = @
    tabletop.init
      key: env.gdoc_key
      simpleSheet: true
      callback: (d,h) ->
        cur.handleQueries d, h

  handleQueries: (data, tabletop) ->
    self = @
    query_set = new QuerySet()
    query_set.loadQueries data, () ->
      self.storage.getMentioned query_set, () ->
        self.updateStream query_set

  updateStream: (qs) ->
    self = @
    if @stream?
      @stream.destroy()

    console.log "\nUpdated stream configuration."
    console.log "> Following " + qs.follows.length + " users..."
    console.log "> Tracking " + qs.tracks.length + " terms..."

    twitter.client.stream 'statuses/filter', qs.toObject(), (stream) ->
      self.stream = stream
      stream.on 'data', (data) ->
        try
          if not data.id?
            console.error data
          else
            self.storage.saveStatus data, (nop) ->
        catch error
          console.error error
      stream.on 'error', (data) ->
        error = '' + data
        console.error 'XXX ' + data

exports.Tracker = Tracker
