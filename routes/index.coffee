test = require "./test"


exports.init = (app) ->

  app.get  '/', test.index
  app.get '/kinecttest', test.kinect