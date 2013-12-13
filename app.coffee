require("bucket-node").initSingletonBucket 'database-name-here.db', (data) ->

  connectCoffeeScript = require('connect-coffee-script')
  io                  = require('socket.io')
  fs                  = require("fs")
  express             = require("express")
  http                = require("http")
  path                = require("path")
  routes              = require ("./routes")
  app                 = express()

  unless fs.existsSync path.join(__dirname, "compiled")
    fs.mkdirSync path.join(__dirname, "compiled")
  unless fs.existsSync path.join(__dirname, "compiled/css")
    fs.mkdirSync path.join(__dirname, "compiled/css")
  unless fs.existsSync path.join(__dirname, "compiled/app")
    fs.mkdirSync path.join(__dirname, "compiled/app")



  app.configure ->
    app.set "port", process.env.PORT or 3500
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use express.favicon()
    app.use express.logger("dev")
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser("lolcat")
    app.use express.session()
    app.use app.router


    app.use '/app', connectCoffeeScript {
      src  : path.join(__dirname, 'client')
      dest : path.join(__dirname, "compiled/app")
    }

    app.use "/css", require("less-middleware")(
      src: __dirname + "/client/less"
      dest: __dirname + "/compiled/css"
      paths: [path.join(__dirname, "compiled", "lib")]
    )

    app.use express.static(path.join(__dirname, "public"))

    app.use '/css', express.static(path.join(__dirname, "compiled/css"))
    app.use '/lib', express.static(path.join(__dirname, "compiled/lib"))
    app.use '/app', express.static(path.join(__dirname, "compiled/app"))

  app.configure "development", ->
    app.use express.errorHandler()

  routes.init(app)
  io = io.listen app.listen(3500)
  console.log 'Listening on port 3500'

  positions = {}
  visitors = {}

  io.sockets.on 'connection',  (socket) ->
    do (socket) ->
      socket.emit 'init',
        visitors: visitors
        positions: positions

      socket.on 'd', (data) ->
        positions[socket.id] = data
        io.sockets.emit 'd', id:socket.id, data:data
      socket.on 'u', (data) ->
        delete positions[socket.id]
        io.sockets.emit 'u', id:socket.id, data:data
      socket.on 'm', (data) ->
        positions[socket.id] = data
        io.sockets.emit 'm', id:socket.id, data:data

      socket.on 'hi', (data) ->
        visitors[socket.id] = data
        io.sockets.emit 'visitor-welcome', {id:socket.id, data:data}

      socket.on 'disconnect', () ->
        delete visitors[socket.id]
        io.sockets.emit 'visitor-godbye', {id:socket.id}

