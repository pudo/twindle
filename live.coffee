queue = require './lib/queue'
config = require './lib/config'
{createApp} = require './lib/web'
{Storage} = require './lib/storage'

class VoteConsumer

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
      console.log self.events

  saveStatus: (status, callback) ->
    self = @
    console.log "Reading: #{status.text}"
    for event, event_data of self.events
      for tag in event_data.tags
        for [regex, value] in tag.sentiments
          if regex.test status.text
            self.saveMatch status, event, tag.name, value
    callback()

  saveMatch: (status, event, tag, value) ->
    console.log 'huhu'


queue.consume "live", new VoteConsumer()

# app = createApp(storage)
# app.listen 4000#config.port

