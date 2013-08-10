{Storage} = require './storage'
amqp = require 'amqp'
env = require './env'

queueOpts = 
    durable: true
    autoDelete: false

connect = (queue_name, callback) ->
    connection = amqp.createConnection
        url: env.amqp_url
        #defaultExchangeName: env.amqp_exchange
    connection.on 'ready', () ->
        exchange = connection.exchange env.amqp_exchange, {type: 'fanout'}, () ->
            name = env.amqp_queue + queue_name
            connection.queue name, (queue) ->   # queueOpts
                queue.bind exchange, ''
                callback connection, exchange, queue
    connection.on 'error', (e) ->
        console.log e

exports.consume = (name, storage) ->
    connect name, (connection, exchange, queue) ->
        #queue.bind '#'
        queue.subscribe {ack: false}, (message, headers, deliveryInfo) ->
            storage.saveStatus message, (ret) ->
                # queue.shift()


class QueuedStorage extends Storage

    connectQueue: (callback) ->
        self = @
        connect "live", (conn, exchange, queue) ->
            self.conn = conn
            self.exchange = exchange
            callback()

    saveStatus: (status, callback) ->
        console.log "Queueing: #{status.id}"
        @exchange.publish env.amqp_queue, status
        callback()

exports.QueuedStorage = QueuedStorage
