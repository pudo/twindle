util = require 'util'
twitter = require './lib/twitter'

showTweet = (id) ->
  twitter.client.get '/statuses/show.json?id=' + id + '&include_entities=true', (data) ->
    console.log util.inspect data


#place:
showTweet '329157712124452866'

#misc
showTweet '329236187963330560'
