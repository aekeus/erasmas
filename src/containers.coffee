{ createable } = require './createable'
{ Thing } = require './thing'

class PersonalContainer extends Thing
  constructor: (@capacity) ->
    super

class Backpack extends Thing
  constructor: () ->
    super

class SmallBag extends Thing
  constructor: () ->
    super

inter =
  PersonalContainer: PersonalContainer
  Backpack: Backpack
  SmallBag: SmallBag

createable.addObject inter

module.exports = inter
