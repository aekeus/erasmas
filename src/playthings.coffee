{ Thing } = require './thing'
{ createable } = require './createable'
{ Event } = require './event'

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

class CupOfCoffee extends Thing
  constructor: () ->
    super

  drink: ->
    this.parent.remove this
    "The coffee tasted great."

  interface:
    drink: 1

class Clock extends Thing
  constructor: () ->
    super

  detailed: ->
    "#{this} says the time is #{new Date()}"

  "look-at": () ->
    new Date()

  interface:
    "look-at": 1

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

class Paper extends Thing
  constructor: ->
    super
    @attributes.contents ||= []

  "write-on": (character, text) ->
    @attributes.contents.push text
    "Wrote #{text}"

  read: (character) ->
    @attributes.contents.join("\r\n")

  interface:
    "write-on": 1
    "read": 1

inter =
  CoffeeMaker: CoffeeMaker
  CupOfCoffee: CupOfCoffee
  Clock: Clock
  OnOff: OnOff
  Paper: Paper

createable.addObject inter
module.exports = inter
