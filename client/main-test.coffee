
$(document).ready () ->
  socket = io.connect '192.168.1.129:3500'
  state = null
  socket.on 'init', (data) ->
    state = data
    socket.emit 'hi',
      name:"MyName"
      locaktion:"location"
      color:'rg'
  socket.on 'visitor-welcome', (data) ->
    state.visitors[data.id] = data.data
    console.dir data
  socket.on 'visitor-godbye', (data) ->
    delete state.visitors[data.id]
    console.dir data
  socket.on 'd', (data) ->
    state.positions[data.id] = data.data
  socket.on 'u', (data) ->
    delete state.positions[data.id]
  socket.on 'm', (data) ->
    state.positions[data.id] = data.data

  mouseState = 'up'

  $('body').mousedown (e) ->
    if state?
      mouseState = 'down'
      socket.emit('d', [e.pageX, e.pageY])
  $('body').mouseup (e) ->
    if state?
      mouseState = 'up'
      socket.emit('u', [e.pageX, e.pageY])
  $('body').mousemove (e) ->
    if state? and mouseState == 'down'
        socket.emit('m', [e.pageX, e.pageY])

