{ createable } = require './createable'
{ Thing } = require './thing'

# a World contains Zones
class World extends Thing
  constructor: ->
    super

  roomByName: (name) ->
    this.search name, one: true

  getEntrance: ->
    this.roomByName "Entrance"

  fullRep: ->
    recurseThingRep = (thing) ->
      buffer = thing.rep()
      buffer.children = {}
      for gid, child of thing.children
        buffer.children[gid] = recurseThingRep child
      buffer

    recurseThingRep this

# Zone is a parent container for Rooms
class Zone extends Thing
  constructor: ->
    super

inter =
  World: World
  Zone: Zone

createable.addObject inter

module.exports = inter
