{ Thing } = require './thing'
{ createable } = require './createable'

class Window extends Thing
  constructor: () ->
    super

  detailed: ->
    destination = registry.get(+@attributes.destination)
    "You see into #{destination.name}"

inter =
  Window: Window

createable.addObject inter
  
module.exports = inter

