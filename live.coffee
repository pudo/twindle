queue = require './lib/queue'
env = require './lib/env'
{createApp} = require './lib/web'

class LiveStorage

    saveStatus: (status, callback) ->
        console.log "Reading: #{status.text}"

       
        callback()


storage = new LiveStorage()
queue.consume "live", storage

# app = createApp(storage)
# app.listen 4000#env.port

