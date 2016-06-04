{ Server } = require './server'
{ Registry } = require './registry'
{ Dispatcher } = require './dispatch'
{ World } = require './world'
{ utils } = require './utils'
{ Character } = require '../dist/character'
{ Door } = require '../dist/door'
{ createable } = require '../dist/createable'

assert = require 'assert'

#
#  The Kernel controls the cycle by cycle workings of the MUSH. It handles the tree update logic, sends and receives messages from
#  connection sockets and is responsible for loading and saving world files.
#
class Kernel
  constructor: (@port = 8000) ->
    @server       = new Server @port, this.connectionHandler
    @registry     = Registry
    @world        = new World "DefaultWorld"
    @dispatcher   = new Dispatcher
    @setupDispatcher @dispatcher

  #
  #  Install logic handler for text commands
  #
  #  dispatcher - Object responsible for installation and matching of commands {Dispatcher}
  #
  setupDispatcher: (dispatcher) ->
    dispatcher.install @logic_save,          "save world to named file",                           "save",     "ALPHANUM"
    dispatcher.install @logic_save,          "save world to default filename",                     "save"
    dispatcher.install @logic_create_character, "create a new character",                          "create", "character", "ALPHANUM", "with", "password", "ALPHANUM"
    dispatcher.install @logic_set,           "set an attribute of a thing to a value",             "set",      "ALPHANUM", "of", "ID", "to", "ALPHANUM"
    dispatcher.install @logic_implicit_set,  "set an attribute of the current thing to a value",   "set",      "ALPHANUM", "to", "ALPHANUM"
    dispatcher.install @logic_append,        "append a value to a list attribute of a thing",      "append",   "ALPHANUM", "to", "ALPHANUM", "of", "ID"
    dispatcher.install @logic_append,        "append a value to a list in the current thing",      "append",   "ALPHANUM", "to", "ALPHANUM"
    for verb in ["inv", "inventory"]
      dispatcher.install @logic_inventory,   "display inventory",                                  verb
    dispatcher.install @logic_link,          "link two rooms via two doors",                       "link",     "ID", "to", "ID"
    dispatcher.install @logic_link,          "link room to current room",                          "link",     "ID"
    dispatcher.install @logic_move,          "move a thing to a new parent",                       "move",     "ID", "to", "ID"
    dispatcher.install @logic_take,          "take a thing",                                       "take",     "ID"
    dispatcher.install @logic_put,           "put a thing in another thing",                       "put",      "ID", "(?:in|on)", "ID"
    dispatcher.install @logic_give,          "give a thing to another character",                  "give",     "ID", "to", "ID"
    dispatcher.install @logic_drop,          "drop a thing",                                       "drop",     "ID"
    dispatcher.install @logic_find,          "find a thing",                                       "find",     "ALPHANUM"
    for verb in ["rm", "del", "delete", "remove"]
      dispatcher.install @logic_rm,          "remove a thing",                                     verb,       "ID"
    dispatcher.install @logic_create_door,   "create a door to a room",                            "create",   "door", "ALPHANUM", "to", "ID"
    dispatcher.install @logic_create_room,   "create a named room",                                "create",   "room", "ALPHANUM"
    dispatcher.install @logic_create_linked_room, "create a named room and link to current room",  "create",   "linked", "room", "ALPHANUM"
    dispatcher.install @logic_create_thing,  "create a named thing",                               "create",   "thing", "ALPHANUM"
    dispatcher.install @logic_create_custom, "create a custom named thing",                        "create",   "CLS", "ALPHANUM"
    dispatcher.install @logic_create_custom, "create a custom thing",                              "create",   "CLS"
    dispatcher.install @logic_create_thing,  "create a thing",                                     "create",   "thing"
    dispatcher.install @logic_copy,          "make a copy of a thing",                             "copy",     "ALPHANUM", "as", "ALPHANUM"
    dispatcher.install @logic_look_at,       "look at a thing",                                    "look",     "at", "ID"
    dispatcher.install @logic_look_at,       "look at a thing",                                    "look",     "ID"
    dispatcher.install @logic_look,          "look at current room",                               "look"
    dispatcher.install @logic_inspect,       "inspect a thing's attributes, children and actions", "inspect",  "ID"
    dispatcher.install @logic_go,            "go through a door",                                  "go",       "ID"
    dispatcher.install @logic_rename,        "rename a thing",                                     "rename",   "ID", "to", "ALPHANUM"
    dispatcher.install @logic_login,         "login with username and password",                   "login",    "ALPHANUM", "ALPHANUM"
    dispatcher.install @logic_logout,        "logout of system",                                   "logout"
    dispatcher.install @logic_say,           "speak to everyone in a room",                        "say",      "ALPHANUM"
    dispatcher.install @logic_modify,        "set the current object to be modified",              "modify",   "ID"
    dispatcher.install @logic_commands,      "show a list of commands",                            "commands"
    dispatcher.install @logic_help,          "show help contents",                                 "help"
#    dispatcher.install @logic_go,            "go through a door",                                  "ALPHANUM"

  #
  #  Start the server listening for connections
  #
  start: ->
    @server.start()

  #
  #  Install a new World object in this Kernel
  #
  #  world - installation world {World}
  #
  installWorld: (world) ->
    @world = world

  #
  #  Retrieve a thing by its id
  #
  #  id - id of Thing to retrieve {Integer}
  #
  thingById: (id) ->
    @registry[id]

  #
  #  Match a string against the first portion of a set of lower case Thing names
  #
  #  search - partial name to search for       {String}
  #  things - array of Things to match against {Array of Things}
  #
  softMatchIn: (search, things) ->
    for gid, thing of things
      return thing if thing.name[0..search.length-1].toLowerCase() is search

  #
  #  Save the world to a JSON file
  #
  #  filename - JSON file to save {String}
  #
  logic_save: (conn, filename) =>
    filename ?= "world.json"
    @saveWorld filename, () =>
      @send conn, "Saved world as \"#{filename}\""
    "Saving"

  #
  #  Load the world from a JSON file
  #
  #  filename - JSON file to load {String}
  #
  logic_load: (conn, filename) =>
    filename ?= "world.json"
    @loadWorld filename, () =>
      @send conn, "World loaded from \"#{filename}\""
    "Loading"

  #
  #  Instruct the current character to say some words to others in the same room
  #
  #  words - words to speak {String}
  #
  logic_say: (conn, words) =>
    conn.character.speak words
    "You say #{words}"

  #
  #  Display list of commands and their descriptions
  #
  logic_commands: (conn) =>
    assert conn.constructor.name is "Connection", "connection required"

    @dispatcher.formattedCommands().join utils.eol

  #
  #  Display contents of help
  #
  #    TODO: make this more helpful
  #
  logic_help: (conn) =>
    assert conn.constructor.name is "Connection", "connection required"

    @dispatcher.formattedCommands().join utils.eol

  #
  #  Place a Thing from your inventory into the inventory of another container
  #
  #  thingSelector     - selector for thing to move {Selector}
  #  containerSelector - selector for target thing  {Selector}
  #
  logic_put: (conn, thingSelector, containerSelector) =>
    thing = conn.character.parent.search thingSelector, one: true
    return utils.notFoundMsg thingSelector unless thing?
    return "#{thing} cannot be moved" if thing.attr("heavy")

    container = conn.character.parent.search containerSelector, one: true
    return utils.notFoundMsg containerSelector unless container?
    return "#{container} cannot contain #{thing}" unless container.isContainer()

    switch @rebaseThing thing, container
      when "CANNOT_REMOVE" then "#{thing} cannot be picked up from #{thing.parent}"
      when "CANNOT_ADD"    then "#{thing} cannot be put #{container.inOn()} #{container}"
      else "#{thing} put #{container.inOn()} #{container}"

  #
  #  Place Thing from your inventory into the inventory of another Character
  #
  #  thingSelector     - selector for thing to move    {Selector}
  #  containerSelector - selector for target Character {Selector}
  #
  logic_give: (conn, thingSelector, charSelector) =>
    thing = conn.character.search thingSelector, one: true
    return utils.notFoundMsg thingSelector unless thing?

    otherChar = conn.character.parent.search charSelector + "[Character]", one: true
    return utils.notFoundMsg otherChar unless otherChar?
    return "You must give #{thing} to another character, not a #{otherChar.constructor.name}" unless otherChar.isa("Character")

    switch @rebaseThing thing, otherChar
      when "CANNOT_REMOVE" then "#{thing} cannot be removed from #{conn.character}"
      when "CANNOT_ADD"    then "#{thing} cannot be given to #{otherChar}"
      else "#{thing} given to #{otherChar}"

  #
  # Display a list of things that match a global selector
  #
  # selector - matching selector {Selector}
  #
  logic_find: (conn, selector) =>
    assert selector, "logic_find - selector required"

    things = @world.search selector
    
    return utils.notFoundMsg selector unless things?.length

    ("#{thing} in #{thing.parent}" for thing in things).join(utils.eol)

  #
  #  Display the contents of a Character's inventory
  #
  logic_inventory: (conn) =>
    assert conn.constructor.name is "Connection", "connection required"

    ("#{thing}" for k, thing of conn.character.children).join(utils.eol)

  #
  #  Instantiate a custom object based on a classname
  #
  #  cls  - name of JavaScript function that creates this object type {String}
  #  name - name of Thing                                             {String} [OPTIONAL]
  #
  logic_create_custom: (conn, cls, name) ->
    assert conn.constructor.name is "Connection", "connection require"
    assert cls?, "cls required"
    name ?= cls

    clsref = createable[cls] || exports[cls]
    return "You cannot create a thing of type #{cls}" unless clsref
    thing = new clsref(name)

    return "Thing of type #{cls} could not be created" unless thing?
    return "#{thing} could not be added to #{conn.character.parent.add}" unless conn.character.parent.canAdd thing
    conn.character.parent.add thing

    "#{thing} created"

  #
  #  Create a generic Thing object with a given name
  #
  #  name - name given to the generic Thing {String}
  #
  logic_create_thing: (conn, name) ->
    thing = new Thing name || "Thing",
      created_by: conn.character.gid
    if conn.character.parent.canAdd thing
      conn.character.parent.add thing
      "#{thing} created"
    else
      "#{conn.character.parent} cannot add #{thing}"

  #
  #  Ask the connection Character to look at its surrounding room
  #
  logic_look: (conn) =>
    conn.character.look()

  #
  #  View information about a specific thing
  #
  #  selector - thing selector {Selector}
  #
  logic_look_at: (conn, selector) =>
    thing = conn.character.parent.search selector,
      one: true,
      soft: true
    return utils.notFoundMsg selector unless thing?
    thing.detailed()

  #
  #  View detailed information about a specific thing
  #
  #  selector - thing selector {Selector}
  #
  logic_inspect: (conn, selector) =>
    thing = @world.search selector, one: true
    return utils.notFoundMsg selector unless thing?
    thing.inspection()

  #
  #  Set this thing to be the object that will be modified by subsequent commands
  #
  #  selector - thing selector {Selector}
  #
  logic_modify: (conn, selector) =>
    thing = @world.search selector, one: true
    return utils.notFoundMsg selector unless thing?
    conn.currentThing = thing
    "You are now modifying #{conn.currentThing}"

  #
  #  Logout of system
  #
  logic_logout: (conn) =>
    conn.disconnect()

  #
  #  Login to a character
  #
  #  name    - character name     {String}
  #  passwor - character password {String}
  #
  logic_login: (conn, name, pwd) =>
    assert name?, "name required"
    assert pwd?,  "pwd required"

    debug "Attempt to connect to character '#{name}'"
    char = @world.search name + "[Character]", one: true
    if char?
      debug "Login to character #{char.mqname()}"
      conn.connect char
      conn.character.parent.add conn.character
      conn.character.look()
    else
      "Cannot login to this character"

  #
  #  Create a new character
  #
  #  name - new character name      {String}
  #  pwd  - new character password  {String}
  #
  logic_create_character: (conn, name, pwd) =>
    assert name?, "name required"
    assert pwd?, "password required"

    char = new Character name, password: pwd
    @world.getEntrance().add char
    conn.connect char
    char.look()

  #
  #  Go through a door
  #
  #  selector - target door selector {Selector -> Door}
  #
  logic_go: (conn, selector) =>
    assert conn.constructor.name is "Connection", "connection required"
    assert selector?, "logic_go - selector required"

    door = conn.character.parent.search(selector + "[Door]", one: true) || @softMatchIn(selector, conn.character.parent.childrenOfType "Door")
    return false unless door?

    destinationRoom = @world.search door.destination(), one: true
    return "Destination room not found." unless destinationRoom?

    [ok, reason] = door.canTraverse(conn.character)
    #debug "ok = #{ok}"
    #debug "reason = #{reason}"
    unless ok
      return "You cannot go to the #{destinationRoom.mqname()} in #{destinationRoom.closestOfType('Zone')?.mqname()}. #{reason}."

    response = @logic_move conn, conn.character.gid, destinationRoom.gid
    response = @logic_look conn unless response
    response

  #
  #  Remove a thing from its parent. Do not re-assign it to a container.
  #
  #  selector - target selector {Selector}
  #
  logic_rm: (conn, selector) =>
    utils.mAssert conn.constructor.name is "Connection", selector?

    thing = @world.search selector, one: true
    return "#{selector} could not be found" unless thing?

    parent = thing.parent
    return "#{thing} has no parent. You cannot drop this thing." unless parent?

    return "#{thing} could NOT be removed from #{parent}" unless parent.canRemove thing
    parent.remove thing
    "#{thing} removed from #{parent}"

  #
  #  Rename a thing
  #
  #  selector - target Thing selector {Selector}
  #  name     - new name              {String}
  #
  logic_rename: (conn, selector, name) =>
    utils.mAssert conn.constructor.name is "Connection", selector?, name?

    thing = @world.search selector, one: true

    return utils.notFoundMsg selector unless thing
    oldName = thing.mqname()
    thing.setName name
    "#{thing.constructor.name} #{oldName} renamed to #{thing.mqname()}"

  #
  #  Append a value to a list attribute of a thing
  #
  #  value     - value to append  {String}
  #  attribute - attribute name   {String}
  #  selector  - target selector  {String} [OPTIONAL]
  #
  logic_append: (conn, value, attribute, selector) =>
    utils.mAssert conn.constructor.name is "Connection", attribute?, value?

    if selector?
      thing = @world.search selector, one: true
      return utils.notFoundMsg selector unless thing
    else
      thing = conn.currentThing || conn.character
    return "#{attribute} cannot be set on #{thing}" unless thing.canSetAttr attribute, value
    current = thing.attr(attribute)
    return "#{attribute} is not a list" unless current? and utils.isArray current

    current.push value
    "\"#{value}\" appended to \"#{attribute}\" of #{thing}"

  #
  #  Set an attribute of a Thing to a value. The value is a string, false, true or a "list"
  #
  #  attribute - name of the attribute    {String}
  #  selector  - target selector          {Selector}
  #  value     - string or special string {String}
  #
  logic_set: (conn, attribute, selector, value) =>
    utils.mAssert conn.constructor.name is "Connection", attribute?, value?, selector?

    target = @world.search selector, one: true
    return utils.notFoundMsg selector unless target?

    return "#{attribute} of #{target} cannot be set to #{value}" unless target.canSetAttr attribute, value
    v = target.attr attribute, value
    "#{attribute} of #{target} set to #{v}"

  #
  #  Set an attribute of the currentThing or the connection character to a value
  #
  #  attribute - name of the attribute      {String}
  #  value     - string or speciial string  {String}
  #
  logic_implicit_set: (conn, attribute, value) =>
    assert conn?, "connection required"
    assert attribute?, "attribute required"
    assert value?, "value required"

    target = conn.currentThing || conn.character

    return "#{attribute} of #{target} cannot be set to #{value}" unless target.canSetAttr attribute, value
    v = target.attr attribute, value
    "#{attribute} of #{target} set to #{v}"

  #
  #  Link two rooms together. Create two doors that share their name with their destination room.
  #  i.e. link Bedroom to Bathroom will create a door named Bathroom in the Bedroom and a door named
  #  Bedroom in the Bathroom.
  #
  #  selector1 - first room selector  {Selector}
  #  selector2 - second room selector {selector}
  #
  logic_link: (conn, selector1, selector2) =>
    utils.mAssert conn.constructor.name is "Connection", selector1?

    room1 = @world.search selector1, one: true
    return utils.notFoundMsg selector1 unless room1?

    if selector2?
      room2 = @world.search selector2, one: true
      return utils.notFoundMsg selector2 unless room2?
    else
      room2 = conn.character.parent

    room1Door = new Door room2.name, destination: room2.gid
    room2Door = new Door room1.name, destination: room1.gid

    return "#{room1Door} cannot be added to #{room1}" unless room1.canAdd room1Door
    return "#{room2Door} cannot be added to #{room2}" unless room2.canAdd room2Door

    room1.add room1Door
    room2.add room2Door
    "#{room1} linked to #{room2} via #{room1Door} and #{room2Door}"

  #
  #  Move a Thing to another thing
  #
  #  selector       - Thing selector   {Selector}
  #  parentSelector - Target selector  {Selector}
  #
  logic_move: (conn, selector, parentSelector) =>
    assert conn.constructor.name is "Connection", "connection required"
    assert selector?, "logic_move - selector required"
    assert parentSelector?, "logic_move - parent selector required"

    thing = @world.search selector, one: true
    return utils.notFoundMsg selector unless thing?

    newParent = @world.search parentSelector, one: true
    return utils.notFoundMsg parentSelector unless newParent?

    oldParent = thing.parent
    return "#{thing} cannot be removed from #{oldParent}" unless oldParent.canRemove thing
    return "#{thing} cannot be added to #{newParent}"     unless newParent.canAdd thing

    oldParent.remove thing
    newParent.add thing
    "#{thing} moved from #{oldParent} to #{newParent}"

  #
  #  Take a thing from the current room and place it in your inventory
  #
  #  selector - thing selector {Selector}
  #
  logic_take: (conn, selector) =>
    assert conn.constructor.name is "Connection", "connection required"
    assert selector?, "logic_take - selector required"

    thing = conn.character.parent.search selector, one: true
    return "#{selector} could not be found"                           unless thing?
    return "You cannot take the #{thing}"                             if thing.attr("heavy")

    switch @rebaseThing thing, conn.character
      when "CANNOT_REMOVE" then "#{thing} cannot be removed from #{conn.character.parent}"
      when "CANNOT_ADD"    then "#{thing} cannot be added to #{conn.character}"
      else "#{thing} taken"

  #
  #  Drop an object from your inventory into the current room
  #
  #  selector - thing selector {Selector}
  #
  logic_drop: (conn, selector) =>
    assert conn.constructor.name is "Connection", "connection required"
    assert selector?, "logic_drop - selector required"

    thing = conn.character.search selector, one: true
    return "#{selector} could not be found" unless thing?

    switch @rebaseThing thing, conn.character.parent
      when "CANNOT_REMOVE" then "#{thing} cannot be removed from #{conn.character}"
      when "CANNOT_ADD"    then "#{thing} cannot be added to #{conn.character.parent}"
      else "#{thing} dropped"

  #
  #  Create a room in the current zone or world
  #
  #  name - name of the new room {String}
  #
  logic_create_room: (conn, name) =>
    assert conn.constructor.name is "Connection", "conn must be a connection"
    assert name?,                                 "name required"

    room = new Room name,
      created_by: conn.character.gid
    container = conn.character.closestOfType("Zone") || @world
    return "#{container} cannot contain #{room}" unless container.canAdd room

    container.add room
    return "#{room} created in #{container}"

  #
  #  Copy an existing object, change its name and add it to the
  #  existing objects parent.
  #
  #  selector - thing selector        {Selector}
  #  name     - name of the new thing {String}
  #
  logic_copy: (conn, selector, name) =>
    assert conn.constructor.name is "Connection", "conn must be a connection"
    assert selector?,                             "selector required"
    assert name?,                                 "name required"

    source = conn.character.parent.search selector, one: true
    return "#{selector} not found" unless source?

    rep = source.rep()
    return "#{rep.type} not createable" unless createable[rep.type]
    clone = new createable[rep.type](name, utils.clone(rep.attributes), null)
    clone.attributes.created_at = new Date().toString()
    clone.attributes.created_by = conn.character.gid

    source.parent.add clone

    return "copied #{selector} as #{name}"

  #
  #  Create a new room and link it to the current room
  #
  #  name - name of the new room and door {String}
  #
  logic_create_linked_room: (conn, name) =>
    assert conn.constructor.name is "Connection", "conn must be a connection"
    assert name?,                                 "name required"

    room = new Room name,
      created_by: conn.character.gid
    container = conn.character.closestOfType("Zone") || @world
    return "#{container} cannot contain #{room}" unless container.canAdd room

    container.add room
    @logic_link conn, room.gid.toString()
    return "#{room} created in #{container} and linked via door"

  #
  #  Create a door in this room - link it to another room
  #
  #  name        - name of the door visible to characters {String}
  #  destination - name of the room to link               {String}
  #
  logic_create_door: (conn, name, destination) =>
    assert conn.constructor.name is "Connection", "logic_create_door - conn must be a connection"
    assert name?,                                 "logic_create_door - name required"
    assert destination?,                          "logic_create_door - destination name required"

    destinationRoom = @world.search destination + "[Room]", one: true
    return "A door must be connected to another room" unless destinationRoom?.isa("Room")

    door = new Door name,
      destination: destinationRoom.gid
      created_by:  conn.character.gid
    return "#{conn.character.parent} cannot add #{door}" unless conn.character.parent.canAdd door

    conn.character.parent.add door
    "#{door} created"

  #
  #  Execute a custom method on an object with optional parameters
  #
  #  tokens - array of tokens from the input parser
  #
  #    tokens[1] is the method name                         {String}
  #    tokens[2..] are the parameters passed to the method  {Array of Strings}
  #
  logic_custom: (conn, tokens) =>
    verb     = tokens[0].toLowerCase()
    selector = tokens[1]

    return "command not recognized" unless selector?

    thing = conn.character.parent.search selector, one: true
    return utils.notFoundMsg selector unless thing?

    method = thing[verb]
    params = tokens[2..]

    return "#{thing} cannot #{verb}" unless method?
    method.call thing, conn.character, params

  #
  #  Change the parent of a thing
  #
  #  thing     - thing to be modified {Thing}
  #  newParent - new parent thing     {Thing}
  #
  #  returns string result of rebase request (CANNOT_REMOVE, CANNOT_ADD, ADDED)
  #
  rebaseThing: (thing, newParent) ->
    assert thing?.isa("Thing"),     "thing required and isa Thing"
    assert newParent?.isa("Thing"), "newParent required and isa Thing"

    return "CANNOT_REMOVE" unless thing.parent.canRemove thing
    return "CANNOT_ADD"    unless newParent.canAdd thing
    return "CANNOT_ADD"    unless newParent.isContainer()

    thing.parent.remove thing
    newParent.add thing

    return "ADDED"

  #
  #  Textual Input handling
  #
  handleInput: (conn, tokens, rawInput) =>
    response = @dispatcher.dispatch conn, rawInput
    response = @logic_custom conn, tokens unless response

    if response
      if utils.isArray(response)
        @send conn, response.join(utils.eol)
      else
        @send conn, response if response?

    return

  #
  #  Send a string to a connection socket {String}
  #
  #  text - string to send {String}
  #
  send: (conn, text) ->
    conn.send text

  #
  #  Save the current world to a JSON document
  #
  #  filename - name of file to save            {String}
  #  doneCB   - callback function when complete {Function}
  #
  saveWorld: (filename="world.json", doneCB) ->
    debug "saving filename as #{filename}"
    fs.writeFile filename, JSON.stringify(@world.fullRep()), (err) ->
      throw err if err
      doneCB()

  #
  #  Load the current world from a JSON document
  #
  #  filename - name of the file to load        {String}
  #  doneCB   - callback function when complete {Function}
  #
  loadWorld: (filename, doneCB) ->
    fs.readFile filename, (err, contents) =>
      throw err if err
      data = JSON.parse(contents)
      wb = new WorldRebuilder(data)
      world = wb.build()
      this.installWorld world
      doneCB()

module.exports.Kernel = Kernel
