tabletop = require 'tabletop'
assert = require 'assert'
url = require 'url'

exports.port = process.env.PORT or 3000

exports.db_url = process.env.DB_URL or 'tcp://localhost/twitter'

exports.amqp_url = process.env.AMQP_URL or 'amqp://guest:guest@localhost:5672'
exports.amqp_queue = process.env.AMQP_QUEUE or 'twindle2'
exports.amqp_exchange = process.env.AMQP_EXCHANGE or 'twindle2'

exports.twitter_lang = process.env.TWITTER_LANG or ''
exports.twitter_dragnet = process.env.TWITTER_DRAGNET and process.env.TWITTER_DRAGNET.length > 0

assert process.env.GOOGLESPREAD_KEY?, 'You must set a search config google doc in GOOGLESPREAD_KEY'
exports.gdoc_key = process.env.GOOGLESPREAD_KEY

assert process.env.CONSUMER_KEY?, 'You must set the twitter config, including: CONSUMER_KEY'
exports.consumer_key = process.env.CONSUMER_KEY

assert process.env.CONSUMER_SECRET?, 'You must set the twitter config, including: CONSUMER_SECRET'
exports.consumer_secret = process.env.CONSUMER_SECRET

assert process.env.ACCESS_TOKEN?, 'You must set the twitter config, including: ACCESS_TOKEN'
exports.access_token = process.env.ACCESS_TOKEN

assert process.env.ACCESS_SECRET?, 'You must set the twitter config, including: ACCESS_SECRET'
exports.access_secret = process.env.ACCESS_SECRET


exports.getTable = (callback) ->
  tabletop.init
    key: exports.gdoc_key
    simpleSheet: true
    callback: callback

