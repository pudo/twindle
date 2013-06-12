tabletop = require 'tabletop'
_ = require 'underscore'
config = require './config'
twitter = require './twitter'


class QuerySet

  constructor: () ->
    @tracks = []
    @follows = []

  loadQueries: (queries, callback) ->
    self = @
    query = queries[0] or {}

    next = () ->
      _queries = queries.slice 1
      if _queries.length
        return self.loadQueries _queries, callback
      return callback()  

    if query.type is 'track'
      self.track query.filter
      return next()
    if query.type is 'follow'
      return self.crawlList query.filter, next
    return next()

  crawlList: (list_name, callback) ->
    self = @
    console.log "Following #{list_name}..."
    [owner, slug] = list_name.split '/'
    query =
      slug: slug
      owner_screen_name: owner
    getListMembers = (query) ->
      twitter.client.get '/lists/members.json', query, (data) ->
        if data.users?
          for user in data.users
            self.follow user.id_str
        if not data.next_cursor? or data.next_cursor is 0
          callback()
        else
          query.cursor = data.next_cursor
          getListMembers query
    getListMembers query

  add: (values, list) ->
    for value in values.split(',')
      value = value.trim().toLowerCase()
      if list.indexOf value == -1
        list.push value

  track: (terms) ->
    @add terms, @tracks
    
  follow: (users) ->
    @add users, @follows

  toObject: () ->
    obj =
      language: 'de'
    if @tracks.length
      obj.track = @tracks.join ',' 
    if @follows.length
      obj.follow = @follows.join ','
    return obj



class Tracker

  constructor: (@storage) ->
    self = @

  track: () ->
    self = @
    @loadQueries()
    cb = () ->
      self.loadQueries()
    setInterval cb, 1000 * 60 * 10

  loadQueries: () ->
    cur = @
    tabletop.init
      key: config.gdoc_key
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
        console.error data

exports.Tracker = Tracker
