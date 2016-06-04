#!/usr/bin/env coffee
{ World, Zone } = require '../dist/world'
{ Room } = require '../dist/room'
{ Character } = require '../dist/character'
{ Door } = require '../dist/door'
{ Thing } = require '../dist/thing'
{ utils } = require '../dist/utils'
{ Kernel } = require '../dist/kernel'
{ Connection } = require '../dist/connection'

tap = require 'tap'

testWorld = ->
  w = new World()
  z = new Zone "Zone"

  r1 = new Room("Room 1")
  r2 = new Room("Room 2")
  entrance = new Room("Entrance")

  c1 = new Character("Character 1")
  c2 = new Character("Character 2")
  c3 = new Character("Character 3")

  d1 = new Door "Room 1", destination: r1.gid

  r1.add(c1)
  r2.add(c2)
  r2.add(c3)

  r2.add(d1)

  z.add r1
  z.add r2
  z.add entrance

  w.add z

  [w, [r1, r2], [c1, c2, c3], [z], [d1]]

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

testThing()
testRoom()
testDoor()
testClosest()
testInputParsing()
testThingFormatting()
testDispatcher()
