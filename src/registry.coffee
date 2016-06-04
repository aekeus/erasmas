gid = 1000

class Registry
  constructor: ->
    @things = {}

  register: (thing) ->
    @things[thing.gid] = thing
    gid = thing.gid + 1 if thing.gid > gid

  list: ->
    [gid, thing.constructor.name, thing.name] for gid, thing of @things

  get: (gid) ->
    gid = parseInt gid, 10
    @things[gid]

module.exports.registry = new Registry
