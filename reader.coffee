{Tracker} = require './lib/tracker'
{QueuedStorage} = require './lib/queue'
env = require './lib/env'

storage = new QueuedStorage()
storage.connectQueue () ->
    tracker = new Tracker(storage)
    tracker.track()
