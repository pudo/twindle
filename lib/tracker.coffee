tabletop = require 'tabletop'
_ = require 'underscore'
config = require './config'
twitter = require './twitter'
events = require 'events'


class Tracker

  constructor: (@storage) ->
    self = @
    @reset()
    @events = new events.EventEmitter()
    
    @events.on 'sub', (type, term) ->
      self.subscribe type, term

    @events.on 'unsub', (type, term) ->
      self.unsubscribe type, term

    @events.on 'update', () ->
      self.updateStream()

  reset: () ->
    @queries = {}
    @feed =
      track: {}
      follow: {}

  track: () ->
    self = @
    @loadQueries()
    cb = () ->
      self.loadQueries()
    setInterval cb, 5000

    reset = () ->
      self.reset()
      self.loadQueries()
    setInterval reset, 1000 * 60 * 60

  loadQueries: () ->
    cur = @
    tabletop.init
      key: config.gdoc_key
      simpleSheet: true
      callback: (d,h) ->
        cur.handleQueries d, h

  handleQueries: (data, tabletop) ->
    existing = _.keys @queries
    queries = {}
    for d in data
      query = new Query @events, d
      if not query.valid()
        continue
      queries[query.key] = query
      if -1 is existing.indexOf query.key
        query.trigger 'sub'
    fresh = _.keys queries
    for key in existing
      if -1 is fresh.indexOf key
        @queries[key].trigger 'unsub'
    @queries = queries
    @storage.getMentioned @events

  subscribe: (type, term) ->
    if @feed[type][term]?
      @feed[type][term]++
    else
      @feed[type][term] = 1

  unsubscribe: (type, term) ->
    if @feed[type][term]?
      if @feed[type][term] > 1
        @feed[type][term]--
      else
        delete @feed[type][term]

  compose: (type) ->
    terms = _.keys @feed[type]
    if terms.length
      terms = _.uniq terms
      return terms.join ','

  updateStream: () ->
    self = @
    #if @stream?
    #  @stream.destroy()

    feed =
      language: 'de'
      follow: @compose 'follow'
      track: @compose 'track'
      #track: 'hochwasser,und,wir,deutschland'

    console.log "\nUpdated stream configuration."
    console.log "> Following " + (_.keys @feed['follow']).length + " users..."
    console.log "> Tracking " + (_.keys @feed['track']).length + " terms..."

    if not feed.follow?
      delete feed.follow
    if not feed.track?
      delete feed.track

    twitter.client.stream 'statuses/filter', feed, (stream) ->
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
        #if error.indexOf('ECONNRESET') != -1
        console.error data
        #  self.updateStream()
      #stream.on 'end', () ->
      #  console.log data
      #  #self.stream = null
      #  #self.updateStream()



class Query

  constructor: (@events, @data) ->
    @key = '' + @data.type + '/' + @data.filter
    @key = @key.trim()

  valid: () ->
    if -1 is ['follow', 'track'].indexOf @data.type
      return false
    if @data.filter.length < 2
      return false
    if @data.label.length < 2
      return false
    return true

  track: (event) ->
    for term in @data.filter.split ','
      @events.emit event, 'track', term
    @events.emit 'update'

  follow: (event) ->
    self = @
    [owner, slug] = @data.filter.split '/'
    query =
      slug: slug
      owner_screen_name: owner
    getListMembers = (query, callback) ->
      twitter.client.get '/lists/members.json', query, (data) ->
        if data.users?
          for user in data.users
            self.events.emit event, 'follow', user.id_str
        if not data.next_cursor? or data.next_cursor is 0
          self.events.emit 'update'
        else
          query.cursor = data.next_cursor
          getListMembers query
    getListMembers query

  trigger: (event) ->
    if @data.type is 'track'
      @track event
    if @data.type is 'follow'
      @follow event

  toJSON: () ->
    @data

exports.Tracker = Tracker
