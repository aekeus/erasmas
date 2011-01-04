class CoffeeMaker extends Thing
  constructor: () ->
    super
    @makingCoffee = false

  start: ->
    @broadcast new Event "talk", this, words: "whir, whir...."
    @makingCoffee = true
    setTimeout () =>
      cup = new CupOfCoffee
      this.parent.add cup
      @broadcast new Event "talk", this, words: "#{this} creates a #{cup}"
      @makingCoffee = false
    , 5000

  interface:
    start: 1

CORE.CoffeeMaker = CoffeeMaker

class CupOfCoffee extends Thing
  constructor: () ->
    super

  drink: ->
    this.parent.remove this
    "The coffee tasted great."

  interface:
    drink: 1

CORE.CupOfCoffee = CupOfCoffee

class Clock extends Thing
  constructor: () ->
    super

  detailed: ->
    "#{this} says the time is #{new Date()}"

  "look-at": () ->
    new Date()

  interface:
    "look-at": 1

CORE.Clock = Clock

class OnOff extends Thing
  constructor: () ->
    super
    @attributes.state ?= "off"

  turn: (character, params) ->
    params[0] ||= "on"
    params[0] = params[0].toLowerCase()
    switch params[0]
      when "on"
        @attributes.state = "on"
        this.broadcast new Event "change", this, "state": @attributes.state
      when "off"
        @attributes.state = "off"
        this.broadcast new Event "change", this, "state": @attributes.state
      else
        "invalid state"

  interface:
    turn: 1

CORE.OnOff = OnOff

class Paper extends Thing
  constructor: ->
    super
    @attributes.contents ||= []

  "write-on": (character, text) ->
    @attributes.contents.push text

  read: (character) ->
    @broadcast new Event "talk", this, words: @attributes.contents.join("\r\n")

  interface:
    "write-on": 1
    "read": 1

CORE.Paper = Paper
exports.Paper = Paper
