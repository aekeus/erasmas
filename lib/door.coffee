class Door extends Thing
  constructor: ->
    super

  destination: ->
    @attributes.destination

  canTraverse: (character) ->
    true

  isContainer: ->
    false

CORE.Door = Door

class LockingDoor extends Door
  constructor: ->
    super
    @attributes.locked = true

  canTraverse: (character) ->
    not @attr("locked")

  hasKey: (character) ->
    attributes = @attributes
    gid = @gid
    ks = character.deepChildrenByFunc (thing) ->
      thing.isa("DoorKey") and thing.attrAny("target_doors", gid)
    ks.length > 0

  lock: (character) ->
    if @hasKey character
      @parent.broadcast { words: "click...locked" }
      @attr("locked", true)
    else
      @parent.broadcast { words: "The door cannot be locked. You need a key for it." }

  unlock: (character) ->
    if @hasKey character
      @parent.broadcast { words: "click...unlocked" }
      @attr("locked", false)
    else
      @parent.broadcast { words: "The door cannot be unlocked. You need a key for it." }

  interface:
    lock: 1
    unlock: 1

CORE.LockingDoor = LockingDoor


class DoorKey extends Thing
  constructor: ->
    super
    @attributes.target_doors ||= []

  isContainer: ->
    false

CORE.DoorKey = DoorKey
