class Room extends Thing
  constructor: () ->
    super

  doors: () -> this.childrenOfType("Door")

  add: (thing) ->
    super
    this.broadcast new Event "add", this, "thing": thing
    this.listenTo thing
    thing.listenTo this

  remove: (thing) ->
    super
    this.ignore thing
    thing.ignore this
    this.broadcast new Event "remove", this, "thing": thing

  doorByName: (name) -> @childrenByName(name)[0]

  hear: (evt) -> @broadcast evt

module.exports.Room = Room
