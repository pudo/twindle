{Tracker} = require './lib/tracker'
{QueuedStorage} = require './lib/queue'

storage = new QueuedStorage()
storage.connectQueue () ->
    tracker = new Tracker(storage)
    tracker.track()
