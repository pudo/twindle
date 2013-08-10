twitter = require 'twitter'
config = require './config'

exports.client = twitter
    consumer_key: config.consumer_key
    consumer_secret: config.consumer_secret
    access_token_key: config.access_token
    access_token_secret: config.access_secret


