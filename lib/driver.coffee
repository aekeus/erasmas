
kernel = new Kernel 8000
kernel.loadWorld "world.json", (err, data) ->
  kernel.start()
  webInterface = new WebInterface kernel.world, kernel
