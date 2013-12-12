
$(document).ready () ->
  socket = io.connect '192.168.1.129:3500'
  socket.on 'init', (data) ->
  socket.on 'visitor-welcome', (data) ->
  socket.on 'visitor-godbye', (data) ->
  socket.on 'd', (data) ->
  socket.on 'u', (data) ->
  socket.on 'm', (data) ->
