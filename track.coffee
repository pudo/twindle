mongodb = require 'mongodb'
twitter = require 'twitter'

feed =
  language: 'de'
  track: '"spiegel.de",cdu,spd,fdp,telekom,politik,piraten'


handleTweet = (coll, data) ->
  console.log "#{data.user.screen_name} (#{data.lang}) -> #{data.text}"
  criteria =
    id: data.id
  opts =
    multi: false
    safe: true
    upsert: true
  coll.update criteria, data, opts, (err, res) ->
    console.log err if err?

readStream = (feed, coll) ->
  client = twitter 
    consumer_key: process.env.CONSUMER_KEY
    consumer_secret: process.env.CONSUMER_SECRET
    access_token_key: process.env.ACCESS_TOKEN
    access_token_secret: process.env.ACCESS_SECRET
  client.stream 'statuses/filter', feed, (stream) ->
  #client.stream 'user', feed, (stream) ->
    console.log 'listening!'
    stream.on 'data', (data) ->
      handleTweet coll, data
    stream.on 'error', (data) ->
      console.log "error"

mongoclient = mongodb.MongoClient.connect 'mongodb://localhost:27017/twindle', (err, db) ->
  collection = db.collection 'tweets'
  readStream feed, collection




