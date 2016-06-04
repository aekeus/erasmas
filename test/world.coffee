#!/usr/bin/env coffee
{ World, Zone } = require '../dist/world'
{ Room } = require '../dist/room'
{ Character } = require '../dist/character'
{ Door } = require '../dist/door'
{ Thing } = require '../dist/thing'

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

testThing()
testRoom()
testDoor()

