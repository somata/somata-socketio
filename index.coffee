socketio = require 'socket.io'
polar = require 'polar'
express = require 'express'
http = require 'http'
somata = require 'somata'
util = require 'util'
{log} = somata.helpers

client = new somata.Client

# Set up Polar using a base express server for Socket.IO to attach to

setup_app = (options) ->

    # Create a base express server
    base_app = express()
    http_server = http.createServer base_app
    io = socketio.listen(http_server)

    # Create the polar app
    options.app = base_app
    app = polar.setup_app options

    setup_io io

    app.client = client
    app.io = io

    app.start = (cb) ->
        http_server.listen app.config.port, ->
            console.log "Listening on :#{ app.config.port }"
            cb() if cb?

    return app

# Setup Socket.io handlers for clients to make `remote` and `subscribe` calls
setup_io = (io) ->

    # Handle new client socket connections
    io.on 'connection', (socket) ->
        log.i "[io.on connection] New connection #{ socket.id }"
        subscriptions = {}

        socket.emit 'hello' # Emit a 'hello' for reconnections

        # Forward 'remote' calls
        socket.on 'remote', (service, method, args..., cb) ->
            console.log "[io.on remote] <#{ socket.id }> #{ service } : #{ method }"
            client.remote service, method, args..., (err, data) ->
                console.log '[client.remote] ' + util.inspect arguments, colors: true
                cb err, data

        # Forward subscriptions by emitting events back over socket
        socket.on 'subscribe', (service, type) ->
            console.log "[io.on subscribe] <#{ socket.id }> #{ service } : #{ type }"
            handler = client.on service, type, (err, event) ->
                socket.emit 'event', service, type, event
            subscriptions[service] ||= {}
            subscriptions[service][type] ||= []
            subscriptions[service][type].push handler

        socket.on 'unsubscribe', (service, type) ->
            console.log '[io.on unsubscribe]', service, type
            subscriptions[service][type].map (sub_id) ->
                client.unsubscribe sub_id
            delete subscriptions[service][type]

        # Unsubscribe from all of a socket's subscriptions
        socket.on 'disconnect', ->
            console.log "[io.on disconnect] <#{ socket.id }>"
            for service, types of subscriptions
                for type, subs of types
                    subs.map (sub_id) ->
                        client.unsubscribe sub_id

module.exports =
    setup_app: setup_app

