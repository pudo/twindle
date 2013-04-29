
tracker = require './lib/tracker'
storage = require './lib/storage'

store = new storage.Storage()
tm = new tracker.Tracker(store)

#tm.loadData()
