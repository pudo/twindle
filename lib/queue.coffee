{Storage} = require './storage'
amqp = require 'amqp'
config = require './config'


connect = (callback) ->
    connection = amqp.createConnection
        url: config.amqp_url
        defaultExchangeName: config.amqp_exchange
    connection.on 'ready', () ->
        queue = connection.queue config.amqp_queue
        callback connection, queue
    connection.on 'error', (e) ->
        console.log e

exports.consume = (storage) ->
    connect (connection, queue) ->
        queue.subscribe {ack: true}, (message, headers, deliveryInfo) ->
            storage.saveStatus message, (ret) ->
                queue.shift()


class QueuedStorage extends Storage

    connectQueue: (callback) ->
        self = @
        connect (conn, queue) ->
            self.conn = conn
            callback()

    saveStatus: (status, callback) ->
        console.log "Queueing: #{status.id}"
        @conn.publish config.amqp_queue, status
        callback()

exports.QueuedStorage = QueuedStorage
