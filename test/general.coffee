#!/usr/bin/env coffee
{ World, Zone } = require '../dist/world'
{ Room } = require '../dist/room'
{ Character } = require '../dist/character'
{ Door } = require '../dist/door'
{ Thing } = require '../dist/thing'
{ utils } = require '../dist/utils'
{ Kernel } = require '../dist/kernel'
{ Connection } = require '../dist/connection'
{ SearchThing } = require '../dist/search'
{ Paper } = require '../dist/playthings'
{ testWorld } = require './lib/fixtures'

tap = require 'tap'

testThing = ->
  t = new Thing "name", "age": 38
  tap.equal t.name, "name", "name"
  tap.equal t.attr("age"), 38, "age attr"
  tap.equal t.attr("foo"), undefined, "undefined attr"

  t.attr "bar", "99"
  tap.equal t.attr("bar"), 99, "attr set"

  tap.ok t.gid?, 'gid defined'
  tap.ok t.gid > 0, "gid > 0"

  rep = t.rep()
  tap.ok rep.gid?, 'rep.gid defined'
  tap.equal rep.name, "name", "rep.name"
  tap.equal rep.attributes.age, 38, 'rep.age'

testRoom = ->
  t = new Room "Entrance"
  tap.equal t.name, "Entrance", "room creation"
  t.add(new Door("West", { "destination": "Unknown" }))
  tap.ok t.doorByName("West")?, "doorByName"
  tap.equal t.doorByName("asdfasd")?, false, "doorByName does not exist"
  rep = t.rep()
  tap.equal rep.name, "Entrance", "rep.name"

testDoor = ->
  d = new Door("North", { destination: "Entrance" })
  tap.equal d.name, "North", "name"
  tap.equal d.constructor.name, "Door", "class name"
  tap.equal d.destination(), "Entrance", "destination name"

testClosest = ->
  [world, rooms, characters] = testWorld()
  tap.equal characters[0].closestOfType("Room").name, "Room 1", "Closest one level"
  tap.equal characters[1].closestOfType("World").name, "World", "Closest two levels"
  tap.equal characters[1].closestOfType("sdhjfksjd"), null, "Closest not found"

testInputParsing = ->
  tokens = utils.parse("hello")
  tap.equal tokens.length, 1, 'simple parse'

  tokens = utils.parse("hello world")
  tap.equal tokens.length, 2, 'simple parse 2'

  tokens = utils.parse('hello "world at large"')
  tap.equal tokens.length, 2, 'quoted parse'

  tap.equal tokens[0], 'hello', 'quoted parse first token'
  tap.equal tokens[1], 'world at large', 'quoted parse second token'

  tokens = utils.parse('hello "world at large" another "quoted token"')
  tap.equal tokens.length, 4, 'quoted parse four tokens'

  tap.equal tokens[3], 'quoted token', 'quoted parse fourth token'

testThingFormatting = ->
  t1 = new Thing("a")
  tap.equal t1.name, "a", "name"
  tap.equal t1.qname(), "\"a\"", "qname"
  tap.equal t1.mqname(), "a", "mqname"

  t2 = new Thing("a b")
  tap.equal t2.name, "a b", "name"
  tap.equal t2.qname(), "\"a b\"", "qname"
  tap.equal t2.mqname(), "\"a b\"", "mqname"

  t3 = new Thing("foo")

  tap.equal utils.textForThings([]), "", "textForArrayOfThings none"
  tap.equal utils.textForThings([t1]), "a", "textForArrayOfThings one"
  tap.equal utils.textForThings([t1, t2]), "a or \"a b\"", "textForArrayOfThings two"
  tap.equal utils.textForThings([t1, t2, t3]), "a, \"a b\" or foo", "textForArrayOfThings three"

testDispatcher = ->
  [world, rooms, characters, zones, doors] = testWorld()
  k = new Kernel
  k.installWorld world

  conn = new Connection null
  conn.connect characters[0]

  [func, matches] = k.dispatcher.method conn, "go North"
  tap.equal func, k.logic_go, "go PLACE"
  tap.equal matches[0], "North", "go PLACE matches"

  [func, matches] = k.dispatcher.method conn, "create TicketAgent \"A Foo Thing\""
  tap.equal func, k.logic_create_custom, "create custom thing - func"

  tap.equal matches[0], "TicketAgent", "Matches for custom create - class"
  tap.equal matches[1], "A Foo Thing", "Matches for custom create - name"

testThingHierarchy = ->
  t    = new Thing("Foo", {})
  bar  = new Thing("Bar")
  bax  = new Thing("Bax")
  flum = new Thing("Flum")
  c1   = new Character("Character 1")

  t.add(bar, bax, flum)
  tap.equal t.numberOfChildren(), 3, "multiple add"
  t.add(c1)
  tap.equal t.numberOfChildren(), 4, "single add"
  t.remove(bax)
  tap.equal t.numberOfChildren(), 3, "single remove"

  found = t.childrenByFunc (child) -> child.name is "Bar"
  tap.equal found.length, 1, "childByFunc"

  tap.equal bar.siblings().length, 2, 'siblings'
  tap.equal t.siblings().length, 0, 'no siblings'

  tap.equal bar.siblingsOfType("Character").length, 1, "siblingsOfType"

  characters = t.removeAllOfType("Character")
  tap.equal characters.length, 1, "one character removed"
  tap.equal t.numberOfChildren(), 2, "removeAllOfType"

  tap.ok t.has(bar), "has"
  tap.ok t.childById(bar.gid), "childById"

  tap.equal t.childrenOfType("Thing").length, 2, "two thing children"
  tap.equal t.childrenOfType("Character").length, 0, "zero character children"

  tap.equal t.childrenByName("Bar").length, 1, "childrenByName"
  tap.equal t.childrenByName("Baaskljdfhr").length, 0, "childrenByName none"

  tap.equal t.childrenByTypeAndName("Thing", "Bar").length, 1, "childrenByTypeAndName"
  tap.equal t.childrenByTypeAndName("Thing", "Baaskljdfhr").length, 0, "childrenByTypeAndName none"

testTickets = ->
  [world, rooms, characters, zones, doors] = testWorld()

  { TicketAgent, TicketDoor } = require '../dist/transports'

  td = new TicketDoor "London",
    destination: rooms[0].gid

  ta = new TicketAgent
  ta.attr("door", td.gid)
  ta.attr("cost", 10)

  tap.equal td.canTraverse(characters[0])[0], false, "cannot traverse without a ticket"

  response = ta.buyticket(characters[0])
  tap.ok response.match(/enough money/g), "not enough money"

  characters[0].attr("money", 50)
  response = ta.buyticket(characters[0])
  tap.ok response.match(/purchased/g), "purchased"

  tap.equal characters[0].attr("money"), 40, 'decrement of character money'

  tickets = characters[0].search "[Ticket]"
  tap.equal tickets.length, 1, "ticket given"

  tap.equal tickets[0].attr("door"), td.gid, "ticket destination"

  tap.equal td.canTraverse(characters[0])[0], true, "can traverse with a ticket"

testCharacterCreation =  ->
  [world, rooms, characters, zones, doors] = testWorld()
  k = new Kernel
  k.installWorld world

  conn = new Connection null

  response = k.logic_create_character conn, "foo", "bar"

  entrance = world.getEntrance()
  char = entrance.search "[Character]", one: true
  tap.ok char?, "new character found"

  tap.equal char.name, "foo", "character name"
  tap.equal char.attr("password"), "bar", "character password"

  tap.equal char.parent, entrance, "character parent is entrance"

testTypes = ->

  t = new Thing
  t.attr("foo", "123")
  tap.equal t.attr("foo"), 123, "Integer set"

  t.attr("foo", "123.45")
  tap.equal t.attr("foo"), 123.45, "Float set"

  t.attr("foo", "a123.45")
  tap.equal t.attr("foo"), "a123.45", "string set"

  t.attr("foo", "\"123\"")
  tap.equal t.attr("foo"), "123", "string set with quotes"

  t.attr("foo", "list")
  tap.ok utils.isArray t.attr("foo"), "list attr"

  t.attr("foo", "true")
  tap.ok t.attr("foo"), "true attr"

  t.attr("foo", "false")
  tap.ok not t.attr("foo"), "false attr"

testAttributesList = ->
  thing = new Thing
  thing.attributes["test"] = [1, 2, 3]
  tap.ok thing.attrAny("test", 1), "found it"
  tap.ok not thing.attrAny("test", 99), "not found it"

testAttributesPush = ->
  thing = new Thing
  thing.attributes["test"] = [1, 2, 3]
  tap.equal thing.attr("test").length, 3, "init"
  thing.attrPush("test", 4)
  tap.equal thing.attr("test").length, 4, "attrPush"
  tap.equal thing.attrPush("test3", 4), undefined, "key not found"

testISA = ->
  c = new Character("Tom")
  tap.ok c.isa("Character"), "ISA same level success"
  tap.ok c.isa("Thing"), "ISA top level"
  tap.ok not c.isa("asdfjhgakjdf"), "ISA failure"

testThingDeepSelection = ->
  w = new World()
  r1 = new Room("Room 1")
  r2 = new Room("Room 2")
  c1 = new Character("Character 1")
  c2 = new Character("Character 2")
  c3 = new Character("Character 3")

  r1.add(c1)
  r2.add(c2)
  r2.add(c3)

  w.add r1
  w.add r2

  tap.equal w.deepHas(c1), true, "deepHas"
  tap.equal w.deepHas({}), false, "deepHas"

  tap.equal w.deepChildrenOfType("Character").length, 3, "deepChildrenOfType"
  tap.equal w.deepChildrenByName("Character 1").length, 1, "deepChildrenByName"
  tap.equal w.deepChildrenByTypeAndName("Character", "Character 2").length, 1, "deepChildrenByTypeAndName"

  tap.equal w.deepChildrenByTypeAndName("Character", "Character 99").length, 0, "deepChildrenByTypeAndName none"


testThing()
testRoom()
testDoor()
testClosest()
testInputParsing()
testThingFormatting()
testDispatcher()
testThingHierarchy()
testTickets()
testCharacterCreation()
testTypes()
testAttributesList()
testAttributesPush()
testISA()
testThingDeepSelection()
