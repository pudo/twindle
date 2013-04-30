util = require 'util'
twitter = require './lib/twitter'

id = '329157712124452866'
twitter.client.get '/statuses/show.json?id=' + id + '&include_entities=true', (data) ->
  console.log util.inspect data.place.bounding_box
