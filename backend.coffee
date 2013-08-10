queue = require './lib/queue'
{Storage} = require './lib/storage'
env = require './lib/env'
{createApp} = require './lib/web'

storage = new Storage()
queue.consume "processing" storage

app = createApp(storage)
app.listen env.port

