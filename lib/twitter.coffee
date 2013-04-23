twitter = require 'twitter'
config = require './config'

exports.client = twitter
    consumer_key: config.consumer_key
    consumer_secret: config.consumer_secret
    access_token_key: config.access_token
    access_token_secret: config.access_secret

#exports.feed =
#  language: 'de'
#  track: '"spiegel.de",cdu,spd,fdp,telekom,politik,piraten'

exports.track = (feed, onData, onError) ->
  exports.client.stream 'statuses/filter', feed, (stream) ->
    stream.on 'data', (data) ->
      onData data
    stream.on 'error', (data) ->
      onError data



