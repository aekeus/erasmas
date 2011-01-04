class Window extends Thing
  constructor: () ->
    super

  detailed: ->
    destination = registry.get(+@attributes.destination)
    "You see into #{destination.name}"

CORE.Window = Window

