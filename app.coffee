{Tracker} = require './lib/tracker'
{Storage} = require './lib/storage'
config = require './lib/config'
{createApp} = require './lib/web'

storage = new Storage()
tracker = new Tracker(storage)
tracker.track()

app = createApp(storage)
app.listen config.port

