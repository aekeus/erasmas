# a World contains Zones
class World extends Thing
  constructor: ->
    super

  roomByName: (name) ->
    rooms = this.childrenByName name
    return rooms[0] if rooms.length

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

CORE.World = World

# Zone is a parent container for Rooms
class Zone extends Thing
  constructor: ->
    super

CORE.Zone = Zone
