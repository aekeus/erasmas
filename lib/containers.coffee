class PersonalContainer extends Thing
  constructor: (@capacity) ->
    super

CORE.PersonalContainer = PersonalContainer

class Backpack extends Thing
  constructor: () ->
    super

CORE.Backpack = Backpack

class SmallBag extends Thing
  constructor: () ->
    super

CORE.SmallBag = SmallBag
