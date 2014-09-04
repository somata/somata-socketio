somata_socketio = require './'

app = somata_socketio.setup_app
    port: 20002

app.get '/', (req, res) ->
    res.render 'base'

app.start()

