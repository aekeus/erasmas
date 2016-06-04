{ Paper } = require '../dist/playthings'

class Createable
  constructor: ->
    @mappings = {}
    
  add: (type, func) ->
    @mappings[type] = func

  byType: (tyoe) ->
    @mappings[type]

createable = new Createable()
createable.add 'Paper', Paper

module.exports.createable = new Createable()
