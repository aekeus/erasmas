class Createable
  constructor: ->
    @mappings = {}
    
  add: (type, func) ->
    @mappings[type] = func

  addObject: (obj) ->
    for k, v of obj
      @add k, v

  byType: (type) ->
    @mappings[type]

createable = new Createable()

module.exports.createable = new Createable()
