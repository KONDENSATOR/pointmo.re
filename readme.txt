Skeleton node project, including:
  server and client side coffeescript
  jade
  less

Using bucket as data layer (see git-hub)

Using bower and npm for package management

client folder contains all client-side coffee-scripts and less (all things that need to be compiled for the client side).
  Those will be compiled to the "compiled" folder, which is included in layout
  (compiled folder will be created if it doesn't exist)
  If, for some reason one wants to use pure javascript on the client side, those js files should be in the public folder, and accessed directly

add routes to routes/index.coffee


