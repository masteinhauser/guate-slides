fs         = require('fs')
express    = require("express")
global.app = express.createServer()
io         = require('socket.io').listen(app)
assets     = require('connect-assets')

ip = '192.168.1.110'
port = '3000'

app.set 'views', __dirname + '/views'

app.configure 'development', -> app.use assets()
app.configure 'production',  -> ip = 'vps.kastlersteinhauser.com'; port = 8502; app.use assets( build: true, buildDir: false, src: __dirname + '/assets', detectChanges: false )

app.use express.static(__dirname + '/assets')

app.get '/', (req,res) -> res.render('slides.jade', {ip: ip, port: port})
app.get '/remote', (req,res) -> res.render 'clicker.jade'

io.enable('browser client minification')  # send minified client
io.enable('browser client etag')          # apply etag caching logic based on version number
io.enable('browser client gzip')          # gzip the file
io.set('log level', 1)                    # reduce logging
# enable all transports (optional if you want flashsocket)
io.set('transports', [
    'websocket'
    , 'flashsocket'
    , 'htmlfile'
    , 'xhr-polling'
    , 'jsonp-polling'
])

slides_io = io.of("/slides")
clicker_io = io.of("/remote")

slideId = 1 # dangerous for a threaded system to do
clicker_io.on "connection", (socket) ->
   socket.emit("startfrom", slideId)
   socket.on "changeto", (id) ->
      slideId = id
      slides_io.emit("changeto", slideId)
      socket.broadcast.emit("changeto", slideId)

slides_io.on "connection", (socket) ->
   socket.emit("startfrom", slideId)
   socket.on "changeto", (id) ->
      slideId = id
      clicker_io.emit("changeto", slideId)
      socket.broadcast.emit("changeto", slideId)

app.listen(port)
console.log("Listening on http://"+ip+":"+port+"/")

pidFile = fs.createWriteStream('/tmp/guate-slides.pid')
pidFile.once 'open', (fd) ->
   pidFile.write(process.pid)

