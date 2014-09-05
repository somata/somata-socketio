# Connect to the Socket.io server

socket = io.connect()

# Call a remote service's method

window.remote = (service, method, args..., cb) ->
    socket.emit 'remote', service, method, args..., cb

# Subscribe to a service's events

subscriptions = {}
window.subscribe = (service, type, cb) ->
    subscriptions[service] ||= {}
    subscriptions[service][type] ||= []
    subscriptions[service][type].push cb
    socket.emit 'subscribe', service, type

# Handle published events

socket.on 'event', (service, type, event) ->
    console.log '[socket.on event]'
    console.log arguments
    if cbs = subscriptions[service][type]
        cbs.map (cb) -> cb event

# Resubscribe when reconnecting

first_connect = true
socket.on 'hello', ->

    # Prevent re-connecting on initial load
    if first_connect
        first_connect = false
        return

    # Re-connect known subscriptions
    for service, types of subscriptions
        for type, fns of types
            socket.emit 'subscribe', service, type

# Make a reference to h

window.h = highland

# Creating event streams

window.eventStream = (service, event) ->
    stream = h()
    subscribe service, event, (value) ->
        stream.write value
    return stream

# Log helper

window.log = h.curry (s, v) ->
    if !v? console.log s
    else console.log '[' + s + ']', v

