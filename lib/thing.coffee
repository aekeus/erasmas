class Thing
  constructor: (@name, @attributes, existingGid) ->
    # key / value pairs of attributes
    @attributes ||= {}

    # global Thing id
    @gid = existingGid || gid += 1
    registry.register this

    # object (k/v) of children {Thing}
    @children = {}

    # parent container {Thing}
    @parent = null

    # other Things listening to me
    @listeners = {}

    # use the class name for the object name if none given
    @name = "#{this.constructor.name}" unless @name

  # subclass children to provide custom description formats
  detailed: ->
    "#{this}#{utils.eol}#{this.description()}"

  inspection: ->
    "#{this} - #{this.description()}" + \
    utils.eol + \
    "Attributes:" + \
    utils.eol + \
    ("  #{k} = #{v}" for k, v of @attributes when k isnt "description").join(utils.eol) + \
    utils.eol + \
    "Children:" + \
    utils.eol + \
    ("  #{c}" for gid, c of @children).join(utils.eol) + \
    utils.eol + \
    "Actions:" + \
    utils.eol + \
    ("  #{k}" for k, v of @interface).join(utils.eol)

  description: -> @attr("description") || ""

  setName: (name) ->
    @name = name
    @broadcast new Event "change", this, "attribute": "name"

  # return quoted name
  qname: () -> "\"#{this.name}\""

  # maybe return a quoted name (if a space exists in the name)
  mqname: () ->
    if this.name.search(" ") != -1
      this.qname()
    else
      this.name

  # build an object representation of this Thing
  rep: ->
    type: @constructor.name
    gid: @gid
    name: @name
    attributes: @attributes
    parent: @parent?.gid

  # generic child search
  search: (selector, args) =>
    assert selector?, "selector required"

    args ||= {}
    searchThing this, selector, args

  # can an attribute be set to a value? redefine in subclasses to provide access control
  canSetAttr: (k, v) ->
    true

  # set and / or return attribute
  attr: (k, v = undefined) ->
    v = utils.parseValue v
    @attributes[k] = v if v?
    @attributes[k]

  # push a value onto an array attribute
  attrPush: (k, v) ->
    @attributes[k]?.push v
    @attributes[k]

  # does any array attribute have a specific value
  attrAny: (k, v) ->
    lst = @attributes[k]
    if lst?
      v in lst
    else
      debug "array attribute not found with key #{k}, keys = " + (k for k, v of @attributes)

  # array of attribute names
  attrNames: () ->
    (k for k, v of @attributes)

  # default string representation
  toString: () ->
    "#{this.name}[#{this.constructor.name}]#{this.gid}"

  listenTo: (thing) ->
    @listeners[thing.gid] = thing

  ignore: (thing) ->
    delete @listeners[thing.gid]

  broadcast: (evt) ->
    for gid, thing of @listeners
      thing.hear evt

  # subclass to implement behaviour
  hear: (evt) ->
#    debug "#{this} hears event of type #{evt.type} from #{evt.source}"

  #
  # Hierarchy methods
  #
  children: () ->
    @children

  siblings: () ->
    if @parent?
      (thing for gid, thing of @parent.children when thing isnt this)
    else
      return []

  siblingsOfType: (type) ->
    (thing for thing in @siblings() when thing.isa(type))

  # subclass this method to determine if thing should be
  # able to contain another thing
  canAdd: (thing) ->
    true

  add: () ->
    return unless this.isContainer()
    for thing in arguments
      if @canAdd thing
        @children[thing.gid] = thing
        thing.parent = this

  # subclass this method to determine if thing should be
  # able to remove a contained thing
  canRemove: (thing) ->
    true

  remove: () ->
    things = []
    for thing in arguments
      thing.parent = null
      things.push thing
      delete @children[thing.gid]
    things

  removeAllOfType: (type) ->
    things = []
    for gid, thing of @children
      if thing.constructor.name is type
        things.push thing
        @remove thing
    things

  # tree traversal
  has: (thing) -> @children[thing.gid]?

  numberOfChildren: () -> (k for k, v of @children).length

  childrenByFunc: (func) -> thing for gid, thing of @children when func(thing)

  childById: (gid) -> @children[gid]

  childrenOfType: (type) ->
    thing for gid, thing of @children when thing.isa(type)

  childrenByName: (name) ->
    thing for gid, thing of @children when thing.name is name

  childrenByTypeAndName: (type, name) ->
    thing for gid, thing of @children when thing.name is name and thing.isa(type)

  deepChildrenByFunc: (func) ->
    results = []
    search = (me, func) ->
      if func(me)
        results.push me
      for gid, child of me.children
        search child, func
    search this, func
    results

  deepHas: (toFind) ->
    results = @deepChildrenByFunc (thing) -> thing is toFind
    results[0]?

  deepChildrenOfType: (type) ->
    @deepChildrenByFunc (thing) -> thing.isa type

  deepChildrenByName: (name) ->
    @deepChildrenByFunc (thing) -> thing.name is name

  deepChildrenByTypeAndName: (type, name) ->
    @deepChildrenByFunc (thing) -> thing.name is name and thing.isa type

  # walk up the tree checking to see if a func passes a test
  # used to find the closest node of a child node
  closestByFunc: (func) ->
    currentParent = this.parent
    while currentParent
      if func(currentParent)
        return currentParent
      else
        currentParent = currentParent.parent
    null

  closest: @closestByFunc

  closestOfType: (type) ->
    @closestByFunc (thing) -> thing.isa type

  # is this class a specified type, or are any of its base classes a specified type
  isa: (className) ->
    me = this
    while me?
      if me.constructor.name is className
        return true
      me = me.constructor.__super__
    return false

  isType: (className) ->
    className is this.constructor.name

  isContainer: ->
    true

  # what word to use when describe where children are placed in relation to this object if a container i.e. on, in, behind etc....
  inOn: ->
    "in"

  interface: -> {}

CORE.Thing = Thing
