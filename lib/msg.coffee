log = (msg) ->
  evt = new LogEvent msg
  puts evt.asText()

class LogEvent
  constructor: (@msg) ->

  # derived classes should override
  asText: ->
    @msg
