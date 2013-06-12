queue = require './lib/queue'
{Storage} = require './lib/storage'
config = require './lib/config'
{createApp} = require './lib/web'

storage = new Storage()
queue.consume storage

app = createApp(storage)
app.listen config.port

