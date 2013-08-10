twitter = require 'twitter'
env = require './env'

exports.client = twitter
    consumer_key: env.consumer_key
    consumer_secret: env.consumer_secret
    access_token_key: env.access_token
    access_token_secret: env.access_secret


