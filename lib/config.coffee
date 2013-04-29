assert = require 'assert'
url = require 'url'

exports.port = process.env.PORT or 3000

exports.db_url = process.env.DB_URL or 'tcp://localhost/twitter'

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
