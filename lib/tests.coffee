QUIET = 0

testWorld = () ->
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

testSet "Closest", () ->
  [world, rooms, characters] = testWorld()
  equals characters[0].closestOfType("Room").name, "Room 1", "Closest one level"
  equals characters[1].closestOfType("World").name, "World", "Closest two levels"
  equals characters[1].closestOfType("sdhjfksjd"), null, "Closest not found"

testSet "Thing", () ->
  t = new Thing("name", { "age": 38 });
  equals t.name, "name", "name"
  equals t.attr("age"), 38, "age attr"
  equals t.attr("foo"), undefined, "undefined attr"

  t.attr "bar", "99"
  equals t.attr("bar"), 99, "attr set"

  ok t.gid?, 'gid defined'
  ok t.gid > 0, "gid > 0"

  rep = t.rep()
  ok rep.gid?, 'rep.gid defined'
  equals rep.name, "name", "rep.name"
  equals rep.attributes.age, 38, 'rep.age'

testSet "Room", () ->
  t = new Room("Entrance")
  equals t.name, "Entrance", "room creation"
  t.add(new Door("West", { "destination": "Unknown" }))
  ok t.doorByName("West")?, "doorByName"
  equals t.doorByName("asdfasd")?, false, "doorByName does not exist"
  rep = t.rep()
  equals rep.name, "Entrance", "rep.name"

testSet "Door", () ->
  d = new Door("North", { destination: "Entrance" })
  equals d.name, "North", "name"
  equals d.constructor.name, "Door", "class name"
  equals d.destination(), "Entrance", "destination name"

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

testSet "Input parsing", () ->
  tokens = utils.parse("hello")
  equals tokens.length, 1, 'simple parse'

  tokens = utils.parse("hello world")
  equals tokens.length, 2, 'simple parse 2'

  tokens = utils.parse('hello "world at large"')
  equals tokens.length, 2, 'quoted parse'

  equals tokens[0], 'hello', 'quoted parse first token'
  equals tokens[1], 'world at large', 'quoted parse second token'

  tokens = utils.parse('hello "world at large" another "quoted token"')
  equals tokens.length, 4, 'quoted parse four tokens'

  equals tokens[3], 'quoted token', 'quoted parse fourth token'

testSet "Thing Hierarchy", () ->
  t    = new Thing("Foo", {})
  bar  = new Thing("Bar")
  bax  = new Thing("Bax")
  flum = new Thing("Flum")
  c1   = new Character("Character 1")

  t.add(bar, bax, flum)
  equals t.numberOfChildren(), 3, "multiple add"
  t.add(c1)
  equals t.numberOfChildren(), 4, "single add"
  t.remove(bax)
  equals t.numberOfChildren(), 3, "single remove"

  found = t.childrenByFunc (child) -> child.name is "Bar"
  equals found.length, 1, "childByFunc"

  equals bar.siblings().length, 2, 'siblings'
  equals t.siblings().length, 0, 'no siblings'

  equals bar.siblingsOfType("Character").length, 1, "siblingsOfType"

  characters = t.removeAllOfType("Character")
  equals characters.length, 1, "one character removed"
  equals t.numberOfChildren(), 2, "removeAllOfType"

  ok t.has(bar), "has"
  ok t.childById(bar.gid), "childById"

  equals t.childrenOfType("Thing").length, 2, "two thing children"
  equals t.childrenOfType("Character").length, 0, "zero character children"

  equals t.childrenByName("Bar").length, 1, "childrenByName"
  equals t.childrenByName("Baaskljdfhr").length, 0, "childrenByName none"

  equals t.childrenByTypeAndName("Thing", "Bar").length, 1, "childrenByTypeAndName"
  equals t.childrenByTypeAndName("Thing", "Baaskljdfhr").length, 0, "childrenByTypeAndName none"

testSet "Thing formatting", () ->
  t1 = new Thing("a")
  equals t1.name, "a", "name"
  equals t1.qname(), "\"a\"", "qname"
  equals t1.mqname(), "a", "mqname"

  t2 = new Thing("a b")
  equals t2.name, "a b", "name"
  equals t2.qname(), "\"a b\"", "qname"
  equals t2.mqname(), "\"a b\"", "mqname"

  t3 = new Thing("foo")

  equals utils.textForThings([]), "", "textForArrayOfThings none"
  equals utils.textForThings([t1]), "a", "textForArrayOfThings one"
  equals utils.textForThings([t1, t2]), "a or \"a b\"", "textForArrayOfThings two"
  equals utils.textForThings([t1, t2, t3]), "a, \"a b\" or foo", "textForArrayOfThings three"

testSet "Thing - deep selection", () ->
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

  equals w.deepHas(c1), true, "deepHas"
  equals w.deepHas({}), false, "deepHas"

  equals w.deepChildrenOfType("Character").length, 3, "deepChildrenOfType"
  equals w.deepChildrenByName("Character 1").length, 1, "deepChildrenByName"
  equals w.deepChildrenByTypeAndName("Character", "Character 2").length, 1, "deepChildrenByTypeAndName"

  equals w.deepChildrenByTypeAndName("Character", "Character 99").length, 0, "deepChildrenByTypeAndName none"

testSet "ISA", () ->
  c = new Character("Tom")
  ok c.isa("Character"), "ISA same level success"
  ok c.isa("Thing"), "ISA top level"
  ok not c.isa("asdfjhgakjdf"), "ISA failure"

testSet "attributes push", () ->
  thing = new Thing
  thing.attributes["test"] = [1, 2, 3]
  equals thing.attr("test").length, 3, "init"
  thing.attrPush("test", 4)
  equals thing.attr("test").length, 4, "attrPush"
  equals thing.attrPush("test3", 4), undefined, "key not found"

testSet "attributes list", () ->
  thing = new Thing
  thing.attributes["test"] = [1, 2, 3]
  ok thing.attrAny("test", 1), "found it"
  ok not thing.attrAny("test", 99), "not found it"

testSet "Event Routing and Registration", () ->
  w = new World
  z = new Zone
  r1 = new Room "Room1"
  c1 = new Character "Character1"

  r1.add c1
  z.add r1
  w.add z

testSet "Kernel logic methods", () ->
  [world, rooms, characters, zones, doors] = testWorld()
  k = new Kernel
  k.installWorld world

  conn = new Connection null
  conn.connect characters[0]

  p = new Paper()
  rooms[0].add p

  response = k.logic_rename conn, "Room 2", "Some New Name"
  equals response, 'Room "Room 2" renamed to "Some New Name"', "response text"
  equals rooms[1].name, "Some New Name", "name change"

  response = k.logic_rename conn, "Room 99", "Some New Name"
  equals response, '"Room 99" not found', "response text - not found"

  response = k.logic_set conn, "foo", "Room 1[Room]", "bar"
  ok response.match /set to/g, "scalar set"
  equals rooms[0].attr("foo"), "bar", "attr after set"

  response = k.logic_set conn, "foo", "Room 1[Room]", "false"
  equals rooms[0].attr("foo"), false, "attr after set"
  ok response.match /set to/g, "false set"

  response = k.logic_set conn, "foo", "Room 1[Room]", "true"
  equals rooms[0].attr("foo"), true, "attr after set"
  ok response.match /set to/g, "true set"

  response = k.logic_set conn, "foo", "Room 1[Room]", "list"
  ok utils.isArray(rooms[0].attr("foo")), "array attr get"

  response = k.logic_append conn, "1", "foo", "Room 1[Room]"
  ok utils.isArray(rooms[0].attr("foo")), "is array"
  lst = rooms[0].attr("foo")
  equals lst.length, 1, "one element attribute list"

  response = k.logic_append conn, "1", "foo", "me1234"
  equals response, '"me1234" not found', "invalid gidName"

  response = k.logic_append conn, "1", "foo1", "Room 1[Room]"
  equals response, 'foo1 is not a list', "not a list"

  response = k.logic_link conn, "Room 1", "Some New Name"
  ok response.match(/linked/), "link created"

  response = k.logic_say conn, "hello"
  ok response.match(/you say/i), "say"

  response = k.logic_commands conn
  ok response.split(/\r\n/).length > 5, "commands"

  response = k.logic_find conn, "27634723"
  ok response.match(/not found/), "not found"

  response = k.logic_find conn, "Room 1"
  ok response.split(/\r\n/).length is 3, "room and door found"

  response = k.logic_find conn, "Room 1[Room]"
  ok response.length > 1, "type designator - room found"

testSet "Kernel logic methods", () ->
  [world, rooms, characters, zones, doors] = testWorld()
  k = new Kernel
  k.installWorld world

  conn = new Connection null
  conn.connect characters[0]

  things = searchThing world, [["name", "is", "Room 2"]]
  equals things.length, 1, "two things found by name"

  things = searchThing world, [["name", "isnt", "Room 2"]]
  equals things.length, 8, "many things found by negation of name"

  things = searchThing world, [["type", "is", "Room"]]
  equals things.length, 3, "two rooms found by type"

  things = searchThing world, [["type", "isa", "Room"]]
  equals things.length, 3, "two rooms found by type ISA"

  things = searchThing world, [["gid", "is", rooms[0].gid]]
  equals things.length, 1, "gid is"

  things = searchThing world, [["gid", "isnt", rooms[0].gid]]
  equals things.length, 8, "gid isnt"

  things = searchThing world, [["gid", "is", rooms[0].gid]], one: true
  ok things.isa("Room"), "gid is with return one"

  things = searchThing world, [["destination", "is", rooms[0].gid]]
  equals things.length, 1, "attr is"

  things = searchThing world, [["destination", "is", rooms[0].gid], ["type", "isa", "Door"]]
  equals things.length, 1, "compound type is and attr is"

  things = searchThing world, rooms[0].gid
  equals things.length, 1, "gid is number"

  things = searchThing world, rooms[0].gid + ""
  equals things.length, 1, "gid is string"

  things = searchThing world, "Room 2"
  equals things.length, 1, "name is string"

  things = searchThing world, "Room 2[Room]"
  equals things.length, 1, "name is string with type designator"

  things = world.search "Room 2[Room]"
  equals things.length, 1, "name is string with type designator"

  things = world.search "[Room]"
  equals things.length, 3, "find all rooms"

testSet "Character creation", () ->
  [world, rooms, characters, zones, doors] = testWorld()
  k = new Kernel
  k.installWorld world

  conn = new Connection null

  response = k.logic_create_character conn, "foo", "bar"

  entrance = world.getEntrance()
  char = entrance.search "[Character]", one: true
  ok char?, "new character found"

  equals char.name, "foo", "character name"
  equals char.attr("password"), "bar", "character password"

  equals char.parent, entrance, "character parent is entrance"

testSet "Integer, Float, String, Array and Boolean attribute sets", () ->

  t = new Thing
  t.attr("foo", "123")
  equals t.attr("foo"), 123, "Integer set"

  t.attr("foo", "123.45")
  equals t.attr("foo"), 123.45, "Float set"

  t.attr("foo", "a123.45")
  equals t.attr("foo"), "a123.45", "string set"

  t.attr("foo", "\"123\"")
  equals t.attr("foo"), "123", "string set with quotes"

  t.attr("foo", "list")
  ok utils.isArray t.attr("foo"), "list attr"

  t.attr("foo", "true")
  ok t.attr("foo"), "true attr"

  t.attr("foo", "false")
  ok not t.attr("foo"), "false attr"

testSet "Tickets", () ->
  [world, rooms, characters, zones, doors] = testWorld()

  td = new TicketDoor "London",
    destination: rooms[0].gid

  ta = new TicketAgent
  ta.attr("door", td.gid)
  ta.attr("cost", 10)

  eq td.canTraverse(characters[0]), false, "cannot traverse without a ticket"

  response = ta.buyticket(characters[0])
  ok response.match(/enough money/g), "not enough money"

  characters[0].attr("money", 50)
  response = ta.buyticket(characters[0])
  ok response.match(/purchased/g), "purchased"

  equals characters[0].attr("money"), 40, 'decrement of character money'

  tickets = characters[0].search "[Ticket]"
  equals tickets.length, 1, "ticket given"

  equals tickets[0].attr("door"), td.gid, "ticket destination"

  eq td.canTraverse(characters[0]), true, "can traverse with a ticket"

runTests()
testStats()
