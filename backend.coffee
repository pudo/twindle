queue = require './lib/queue'
{Storage} = require './lib/storage'
config = require './lib/config'
{createApp} = require './lib/web'

storage = new Storage()
queue.consume "processing", storage

app = createApp(storage)
app.listen config.port

