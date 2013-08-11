queue = require './lib/queue'
config = require './lib/config'
{createApp} = require './lib/web'
{Storage} = require './lib/storage'

class VoteManager

  constructor: () ->
    self = @
    self.events = {}
    config.getTable (data) ->
      event_name = null
      for row in data
        if row.type == 'event'
          event_name = row.filter
          self.events[event_name] =
            name: row.filter
            label: row.label
            tags: []
        else if row.type == 'track' and event_name isnt null
          s = [[new RegExp("##{row.filter}\\+", 'mi'), 1],
               [new RegExp("##{row.filter}-", 'mi'), -1]]
          self.events[event_name].tags.push
            name: row.filter
            label: row.label
            sentiments: s
    self.storage = new Storage()

  saveStatus: (status, callback) ->
    self = @
    #console.log "Reading: #{status.text}"
    for event, event_data of self.events
      for tag in event_data.tags
        for [regex, value] in tag.sentiments
          if regex.test status.text
            self.saveVote status, event, tag.name, value
    callback()

  saveVote: (status, event, tag, value) ->
    console.log "Vote: #{event}: #{tag} - #{value}: #{status.text}"
    @storage.client.query 'INSERT INTO "vote" (status_id, event, tag, sentiment, created_at)
      VALUES ($1, $2, $3, $4, NOW())', [status.id, event, tag, value], (err, result) -> 
        if err?
          console.log err

  getVotes: (event, length, freq, callback) ->
    self = @
    @storage.client.query "SELECT v.tag AS tag, v.sentiment AS sentiment,
        TIMESTAMP WITH TIME ZONE 'epoch' + INTERVAL '1 second' *
        round(extract('epoch' from v.created_at) / $1) * $1 AS sample,
        COUNT(v.id) AS count
        FROM vote v
        WHERE v.created_at > NOW() - (INTERVAL '1 second' * $2)
        AND v.event = $3
        GROUP BY v.tag, v.sentiment, round(extract('epoch' from created_at) / $1)
        ORDER BY sample DESC
        ", [freq, length, event], (err, res) ->
      if err?
        return callback null, err
      callback res.rows, null


votemanager = new VoteManager()
queue.consume "live", votemanager

app = createApp
  generateStatistics: (cb) -> cb {}
  getLatest: (cb) -> cb {}

app.all '/*', (req, res, next) ->
  res.set "Access-Control-Allow-Origin", "*"
  res.set "Access-Control-Allow-Headers", "X-Requested-With"
  next()


app.get '/votes', (req, res) ->
  if not req.query.event or not votemanager.events[req.query.event]?
    return res.jsonp 400,
      status: 'error'
      message: "No such event: #{req.query.event}"
  length = Math.min 84600, (parseInt(req.query.length, 10) || 7200)
  freq = Math.max 10, (parseInt(req.query.freq, 10) || 10)
  votemanager.getVotes req.query.event, length, freq, (rows, err) ->
    if err?
      res.jsonp 500,
        status: 'error',
        message: '' + err
    latest = null
    for row in rows
      my_latest = new Date(row.sample)
      if my_latest > latest
        latest = my_latest
    if latest isnt null
    	latest = latest.getTime()
    etag = "#{req.query.event}-#{length}-#{freq}-#{latest}"
    res.set
      'ETag': etag
      'Cache-Control': "public; max-age: #{freq}"
    res.jsonp 200,
      status: 'ok'
      length: length
      freq: freq
      event: votemanager.events[req.query.event]
      data: rows

app.listen 4000 #config.port

