index = (req, res) ->
  res.render 'index'

exports.init = (app) ->
  app.get  '/', index

