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

testKernelLogic1 = ->
  [world, rooms, characters, zones, doors] = testWorld()
  k = new Kernel
  k.installWorld world

  conn = new Connection null
  conn.connect characters[0]

  p = new Paper()
  rooms[0].add p

  response = k.logic_rename conn, "Room 2", "Some New Name"
  tap.equal response, 'Room "Room 2" renamed to "Some New Name"', "response text"
  tap.equal rooms[1].name, "Some New Name", "name change"

  response = k.logic_rename conn, "Room 99", "Some New Name"
  tap.equal response, '"Room 99" not found', "response text - not found"

  response = k.logic_set conn, "foo", "Room 1[Room]", "bar"
  tap.ok response.match /set to/g, "scalar set"
  tap.equal rooms[0].attr("foo"), "bar", "attr after set"

  response = k.logic_set conn, "foo", "Room 1[Room]", "false"
  tap.equal rooms[0].attr("foo"), false, "attr after set"
  tap.ok response.match /set to/g, "false set"

  response = k.logic_set conn, "foo", "Room 1[Room]", "true"
  tap.equal rooms[0].attr("foo"), true, "attr after set"
  tap.ok response.match /set to/g, "true set"

  response = k.logic_set conn, "foo", "Room 1[Room]", "list"
  tap.ok utils.isArray(rooms[0].attr("foo")), "array attr get"

  response = k.logic_append conn, "1", "foo", "Room 1[Room]"
  tap.ok utils.isArray(rooms[0].attr("foo")), "is array"
  lst = rooms[0].attr("foo")
  tap.equal lst.length, 1, "one element attribute list"

  response = k.logic_append conn, "1", "foo", "me1234"
  tap.equal response, '"me1234" not found', "invalid gidName"

  response = k.logic_append conn, "1", "foo1", "Room 1[Room]"
  tap.equal response, 'foo1 is not a list', "not a list"

  response = k.logic_link conn, "Room 1", "Some New Name"
  tap.ok response.match(/linked/), "link created"

  response = k.logic_say conn, "hello"
  tap.ok response.match(/you say/i), "say"

  response = k.logic_commands conn
  tap.ok response.split(/\r\n/).length > 5, "commands"

  response = k.logic_find conn, "27634723"
  tap.ok response.match(/not found/), "not found"

  response = k.logic_find conn, "Room 1"
  tap.ok response.split(/\r\n/).length is 3, "room and door found"

  response = k.logic_find conn, "Room 1[Room]"
  tap.ok response.length > 1, "type designator - room found"

  # TODO - test createable and copy kernel logic

testKernelLogic2 = ->
  [world, rooms, characters, zones, doors] = testWorld()
  k = new Kernel
  k.installWorld world

  conn = new Connection null
  conn.connect characters[0]

  things = SearchThing world, [["name", "is", "Room 2"]]
  tap.equal things.length, 1, "two things found by name"

  things = SearchThing world, [["name", "isnt", "Room 2"]]
  tap.equal things.length, 8, "many things found by negation of name"

  things = SearchThing world, [["type", "is", "Room"]]
  tap.equal things.length, 3, "two rooms found by type"

  things = SearchThing world, [["type", "isa", "Room"]]
  tap.equal things.length, 3, "two rooms found by type ISA"

  things = SearchThing world, [["gid", "is", rooms[0].gid]]
  tap.equal things.length, 1, "gid is"

  things = SearchThing world, [["gid", "isnt", rooms[0].gid]]
  tap.equal things.length, 8, "gid isnt"

  things = SearchThing world, [["gid", "is", rooms[0].gid]], one: true
  tap.ok things.isa("Room"), "gid is with return one"

  things = SearchThing world, [["destination", "is", rooms[0].gid]]
  tap.equal things.length, 1, "attr is"

  things = SearchThing world, [["destination", "is", rooms[0].gid], ["type", "isa", "Door"]]
  tap.equal things.length, 1, "compound type is and attr is"

  things = SearchThing world, rooms[0].gid
  tap.equal things.length, 1, "gid is number"

  things = SearchThing world, rooms[0].gid + ""
  tap.equal things.length, 1, "gid is string"

  things = SearchThing world, "Room 2"
  tap.equal things.length, 1, "name is string"

  things = SearchThing world, "Room 2[Room]"
  tap.equal things.length, 1, "name is string with type designator"

  things = world.search "Room 2[Room]"
  tap.equal things.length, 1, "name is string with type designator"

  things = world.search "[Room]"
  tap.equal things.length, 3, "find all rooms"

  things = world.search "entr",
    soft: true
  tap.equal things.length, 1, "one soft match"

testKernelLogic1()
testKernelLogic2()
