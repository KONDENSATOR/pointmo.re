test = require "./test"

index = (req, res) ->
  res.render 'index'

exports.init = (app) ->

  app.get  '/', index
  app.get '/kinecttest', test.kinect