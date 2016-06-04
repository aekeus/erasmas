class PersonalContainer extends Thing
  constructor: (@capacity) ->
    super

class Backpack extends Thing
  constructor: () ->
    super

class SmallBag extends Thing
  constructor: () ->
    super

module.exports =
  PersonalContainer: PersonalContainer
  Backpack: Backpack
  SmallBag: SmallBag
