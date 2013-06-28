{Tracker} = require './lib/tracker'
{QueuedStorage} = require './lib/queue'
config = require './lib/config'

storage = new QueuedStorage()
storage.connectQueue () ->
    tracker = new Tracker(storage)
    tracker.track()
