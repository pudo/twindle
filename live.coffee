queue = require './lib/queue'
config = require './lib/config'
{createApp} = require './lib/web'

class LiveStorage

    saveStatus: (status, callback) ->
        console.log "Reading: #{status.text}"

       
        callback()


storage = new LiveStorage()
queue.consume storage

# app = createApp(storage)
# app.listen 4000#config.port

