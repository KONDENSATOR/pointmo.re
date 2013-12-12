w = 321
h = 485
opacity = 0.5
radius = 5
circles = {}

stage = new Kinetic.Stage(
  container: "container"
  width: w
  height: h
)
layer = new Kinetic.Layer()
stage.add(layer)

createCircle = (x, y, rgb) ->
  new Kinetic.Circle
    x: x
    y: y
    radius: radius
    fillRGB: rgb
    opacity: opacity

parseColorString = (string) ->
  r: if string.contains("r") then 255 else 0
  g: if string.contains("g") then 255 else 0
  b: if string.contains("b") then 255 else 0

addCircleForUser = (id, data, colorString) ->
  console.log "New circle"
  console.dir data
  circle = createCircle data[0], data[1], parseColorString colorString
  circles[id] = circle
  layer.add circle
  layer.batchDraw()

removeCircleForUser = (id) ->
  console.log "Remove circle"
  circles[id]?.destroy()
  delete circles[id]
  layer.batchDraw()

moveCircleForUser = (id, data) ->
  console.log "Move circle"
  circles[id]?.setPosition data[0], data[1]
  layer.batchDraw()

$(document).ready () ->
  socket = io.connect '127.0.0.1:3500'
  state = null
  socket.on 'init', (data) ->
    console.dir "init start"
    state = data
    socket.emit 'hi',
      name:"MyName"
      locaktion:"location"
      color:'r'
    console.dir "init done"
  socket.on 'visitor-welcome', (data) ->
    state.visitors[data.id] = data.data
    console.dir data
  socket.on 'visitor-godbye', (data) ->
    delete state.visitors[data.id]
    removeCircleForUser(data.id)
    console.dir data
  socket.on 'd', (data) ->
    state.positions[data.id] = data.data
    addCircleForUser(data.id, data.data, state.visitors[data.id].color)
  socket.on 'u', (data) ->
    delete state.positions[data.id]
    removeCircleForUser(data.id)
  socket.on 'm', (data) ->
    state.positions[data.id] = data.data
    moveCircleForUser(data.id, data.data)

  mouseState = 'up'

  $('#container').mousedown (e) ->
    console.log "mouse down"
    if state?
      mouseState = 'down'
      socket.emit('d', [e.pageX, e.pageY])
  $('#container').mouseup (e) ->
    if state?
      mouseState = 'up'
      socket.emit('u', [e.pageX, e.pageY])
  $('#container').mousemove (e) ->
    if state? and mouseState == 'down'
      socket.emit('m', [e.pageX, e.pageY])

