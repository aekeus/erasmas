# Legacy

testSet "Character enters room", () ->
  r = new Room("Room 1")
  c1 = new Character("Character 1")
  c2 = new Character("Character 2")
  c3 = new Character("Character 3")

  c1.enterRoom r
  c2.enterRoom r
  c3.enterRoom r

  c1.speak "hello room"

  c2.leaveRoom r

  c1.speak "hello"
  c3.speak "hello"

testSet "Event Routing and Registration", () ->
  w = new World
  z = new Zone
  r1 = new Room "Room1"
  c1 = new Character "Character1"

  r1.add c1
  z.add r1
  w.add z
