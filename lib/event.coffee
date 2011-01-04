class Event
  constructor: (@type, @source, @contents = {}) ->
    throw "event must contain a source" unless @source
    throw "event must contain a type"   unless @type
    unless Event.validEvents[@type]
      debug @type
      throw "invalid event type"

Event.validEvents =
  change: 1
  add:    1
  remove: 1
  talk:   1
