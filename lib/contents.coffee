class Contents
  constructor: ->
    @thingsById = {}
    @things = []

  has: (thing) -> @thingsById[thing.gid]?

  add: (thing) ->
    unless this.has thing
      @thingsById[thing.gid] = thing
      @things.push thing

  remove: (thing) ->
    idx = @things.indexOf(thing)
    delete @thingsById[@things[idx].gid]
    @things.splice(idx, 1)

  removeAllOfType: (type) ->
    foundThings = this.findByType(type)
    for foundThing in foundThings
      this.remove foundThing

  length: -> @things.length

  size: -> this.length()

  findById: (id) -> @thingsById[id]

  findByType: (type) -> x for x in @things when x.constructor.name is type

  findByName: (name) -> x for x in @things when x.name is name

  findByTypeAndName: (type, name) -> x for x in @things when x.name is name and x.constructor.name is type

