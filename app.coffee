{Tracker} = require './lib/tracker'
{Storage} = require './lib/storage'
env = require './lib/env'
{createApp} = require './lib/web'

storage = new Storage()
tracker = new Tracker(storage)
tracker.track()

app = createApp(storage)
app.listen env.port

