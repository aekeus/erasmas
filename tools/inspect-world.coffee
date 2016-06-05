fs = require 'fs'
util = require 'util'

json = JSON.parse(fs.readFileSync('./misc/world.json.archive', 'utf-8'))
console.log util.inspect json, depth: null
