buildSampleWorld = (w) ->
  entrance = new Room("Entrance")
  room1 = new Room("Room 1")
  room2 = new Room("Room 2")
  secretRoom = new Room("Secret Room")
  chair = new Chair("Nice Chair")

  entrance.addDoor(new Door("West", { destination: room1 }))
  entrance.addDoor(new Door("East", { destination: room2 }))
  entrance.add(chair)

  room1.addDoor(new Door("East",   { destination: entrance   }))
  room1.addDoor(new Door("Secret", { destination: secretRoom }))
  room2.addDoor(new Door("West",   { destination: entrance   }))

  c1 = new Character("Character 1", { password: "password" })
  c2 = new Character("Character 2", { password: "password" })
  c3 = new Character("Character 3", { password: "password" })

  c1.add(new Backpack())
  c2.add(new SmallBag())

  entrance.add(c1)
  entrance.add(c2)
  entrance.add(c3)

  w.add(room1)
  w.add(room2)
  w.add(entrance)

module.exports.buildSampleWorld = buildSampleWorld
