var fs = require('fs')
var path = require('path')
var kernel = require('./dist/kernel')

var configFilename =  'development.config.json'
if (process.env.PROD) {
  configFilename = 'production.config.json'
}

var config = JSON.parse(fs.readFileSync(path.join('config', configFilename), 'utf-8'))

var worldFilename = path.join(
		process.env.LOCATION || config.autosave.location,
		process.env.WORLD || config.world
)

var k = new kernel.Kernel(config)
k.loadWorld(worldFilename, function() {
  k.start()
})
