w = 321
h = 485
opacity = 0.1
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
  circle = createCircle data[0], data[1], parseColorString colorString
  circles[id] = circle
  layer.add circle
  layer.batchDraw()

removeCircleForUser = (id) ->
  circles[id]?.destroy()
  delete circles[id]
  layer.batchDraw()

moveCircleForUser = (id, data) ->
  circles[id]?.setPosition data[0], data[1]
  layer.batchDraw()

$(document).ready () ->
  do () ->
    socket = io.connect '192.168.1.130:3500'
    state = null
    socket.on 'disconnect', ->
      ids = _.keys state.visitors
      removeCircleForUser(id) for id in ids
      state = null


    socket.on 'init', (data) ->
      console.log data.positions
      _.each data.positions, (position, id) ->
        console.log "Hej"
      state = data

      socket.emit 'hi',
        name:"MyName"
        location:"location"
        color:'r'

    socket.on 'visitor-welcome', (data) ->
      if state?
        state.visitors[data.id] = data.data
    socket.on 'visitor-godbye', (data) ->
      if state?
        delete state.visitors[data.id]
        removeCircleForUser(data.id)
    socket.on 'd', (data) ->
      if state?
        addCircleForUser(data.id, data.data, state.visitors[data.id].color)
    socket.on 'u', (data) ->
      if state?
        removeCircleForUser(data.id)
    socket.on 'm', (data) ->
      if state?
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
    $('#container').mousemove _.throttle((e) ->
      if state? and mouseState == 'down'
        socket.emit('m', [e.pageX, e.pageY])
    , 1000/30)
