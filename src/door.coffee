{ Thing } = require './thing'
{ createable } = require './createable'

class Door extends Thing
  constructor: ->
    super

  destination: -> @attr("destination")

  canTraverse: (character) -> [true, null]

  isContainer: -> false

class LockingDoor extends Door
  constructor: ->
    super
    @attributes.locked = true

  canTraverse: (character) ->
    [not @attr("locked"), "It is locked"]

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

class DoorKey extends Thing
  constructor: ->
    super
    @attributes.target_doors ||= []

  isContainer: ->
    false

inter =
  Door: Door
  LockingDoor: LockingDoor
  DoorKey: DoorKey

createable.addObject inter

module.exports = inter
