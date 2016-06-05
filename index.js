var kernel = require('./dist/kernel')

var s = new kernel.Kernel(9002)
s.loadWorld('./misc/world.json.archive', function() {
  s.start()
})
