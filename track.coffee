mongodb = require 'mongodb'
twitter = require 'twitter'

feed = 
  track: '#aufschrei'

handleTweet = (coll, data) ->
  console.log "#{data.screen_name} -> #{data.text}"
  coll.insert data, (err, res) ->
    console.log err if err?

readStream = (feed, coll) ->
  tclient = twitter 
    consumer_key: process.env.CONSUMER_KEY
    consumer_secret: process.env.CONSUMER_SECRET
    access_token_key: process.env.ACCESS_TOKEN
    access_token_secret: process.env.ACCESS_SECRET
  tclient.stream 'statuses/filter', feed, (stream) ->
    stream.on 'data', (data) ->
      handleTweet coll, data

mongoclient = mongodb.MongoClient.connect 'mongodb://localhost:27017/newstrack', (err, db) ->
  collection = db.collection 'tweets'
  readStream feed, collection




