#w = 321
#h = 485
#opacity = 0.1
#radius = 5
#circles = {}

#stage = new Kinetic.Stage(
  #container: "container"
  #width: w
  #height: h
#)
#layer = new Kinetic.Layer()
#stage.add(layer)

createCircle = (id, x, y, rgb) ->
  """
  <div id="#{id}" class="usercircle" style="width:10px;height:10px;position:absolute;display:block;opacity:0.4;left:#{x}px;top:#{y}px;background-color:#{rgb};">&nbsp;</div>
  """
  #new Kinetic.Circle
    #x: x
    #y: y
    #radius: radius
    #fillRGB: rgb
    #opacity: opacity

parseColorString = (color) ->
  string = color.toString()
  res = "#"
  res += if string.indexOf("r") != -1 then "FF" else "00"
  res += if string.indexOf("g") != -1 then "FF" else "00"
  res += if string.indexOf("b") != -1 then "FF" else "00"
  res

addCircleForUser = (id, data, colorString) ->
  circle = createCircle id, data[0], data[1], parseColorString colorString
  $('body').append(circle)

removeCircleForUser = (id) ->
  $("##{id}").remove()

moveCircleForUser = (id, data) ->
  $("##{id}").css(left:data[0], top:data[1])
  #circles[id]?.setPosition data[0], data[1]
  #layer.batchDraw()

$(document).ready () ->
  do () ->
    socket = io.connect 'pointmo.re:3500'
    state = null
    socket.on 'disconnect', ->
      ids = _.keys state.visitors
      #removeCircleForUser(id) for id in ids
      state = null


    socket.on 'init', (data) ->
      console.log data.positions
      state = data
      _.each data.positions, (position, id) ->
        addCircleForUser(id, position, state.visitors[id].color)

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

    THROTTLE = 1000/15
    mouseState = 'up'

    lastmsg = {}

    equalsMsg = (newmsg) ->
      newmsg.msg == lastmsg.msg and
        newmsg.coordinates[0] == lastmsg.coordinates[0] and
        newmsg.coordinates[1] == lastmsg.coordinates[1]

    emitTouchPosition = (e, msg) ->
      touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0]
      newmsg = {msg:msg, coordinates:[touch.pageX, touch.pageY]}
      unless equalsMsg(newmsg)
        lastmsg = newmsg
        socket.emit(newmsg.msg, newmsg.coordinates)

    emitClickPosition = (e, msg) ->
      newmsg = {msg:msg, coordinates:[e.pageX, e.pageY]}
      unless equalsMsg(newmsg)
        lastmsg = newmsg
        socket.emit(newmsg.msg, newmsg.coordinates)

    $('body').mousedown (e) ->
      console.log "mouse down"
      if state?
        mouseState = 'down'
        emitClickPosition e, 'd'
    $('body').mouseup (e) ->
      if state?
        mouseState = 'up'
        emitClickPosition e, 'u'
    $('body').mousemove _.throttle((e) ->
      if state? and mouseState == 'down'
        emitClickPosition e, 'm'
    , THROTTLE)


    $('body').bind 'touchstart', (e) ->
      e.preventDefault()
      console.log "mouse down"
      if state?
        mouseState = 'down'
        emitTouchPosition(e, 'd')

    $('body').bind 'touchend', (e) ->
      e.preventDefault()
      if state?
        mouseState = 'up'
        emitTouchPosition(e, 'u')

    $('body').bind 'touchcancel', (e) ->
      e.preventDefault()
      if state?
        mouseState = 'up'
        emitTouchPosition(e, 'u')

    $('body').bind 'touchmove', _.throttle((e) ->
      e.preventDefault()
      if state? and mouseState == 'down'
        emitTouchPosition(e, 'm')
    , THROTTLE)
