{ World, Zone } = require '../../dist/world'
{ Room } = require '../../dist/room'
{ Character } = require '../../dist/character'
{ Door } = require '../../dist/door'
{ Thing } = require '../../dist/thing'
{ utils } = require '../../dist/utils'

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

module.exports =
  testWorld: testWorld
