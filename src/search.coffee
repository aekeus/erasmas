comp = name: {}, type: {}, gid: {}, attr: {}

comp.name["isa"]    = (thing, value) -> throw "ISA not defined for name"
comp.name["is"]     = comp.name["="]  = (thing, attrName, value) -> thing.name is   value
comp.name["isnt"]   = comp.name["!="] = (thing, attrName, value) -> thing.name isnt value
comp.name["gt"]     = comp.name[">"]  = (thing, attrName, value) -> thing.name >    value
comp.name["gte"]    = comp.name[">="] = (thing, attrName, value) -> thing.name >=   value
comp.name["lt"]     = comp.name["<"]  = (thing, attrName, value) -> thing.name <    value
comp.name["lte"]    = comp.name["<="] = (thing, attrName, value) -> thing.name <=   value
comp.name["start"]  = (thing, attrName, value) ->
  re = new RegExp "^#{value}", "i"
  thing.name.match(re)?

comp.type["isa"]  = (thing, attrName, value) -> thing.isa(value)
comp.type["is"]   = comp.type["="]  = (thing, attrName, value) -> thing.constructor.name is   value
comp.type["isnt"] = comp.type["!="] = (thing, attrName, value) -> thing.constructor.name isnt value
comp.type["gt"]   = comp.type[">"]  = (thing, attrName, value) -> thing.constructor.name >    value
comp.type["gte"]  = comp.type[">="] = (thing, attrName, value) -> thing.constructor.name >=   value
comp.type["lt"]   = comp.type["<"]  = (thing, attrName, value) -> thing.constructor.name <    value
comp.type["lte"]  = comp.type["<="] = (thing, attrName, value) -> thing.constructor.name <=   value

comp.gid["isa"]   = (thing, attrName, value) -> throw "ISA not defined for gid"
comp.gid["is"]    = comp.gid["="]   = (thing, attrName, value) -> thing.gid is   value
comp.gid["isnt"]  = comp.gid["!="]  = (thing, attrName, value) -> thing.gid isnt value
comp.gid["gt"]    = comp.gid[">"]   = (thing, attrName, value) -> thing.gid >    value
comp.gid["gte"]   = comp.gid[">="]  = (thing, attrName, value) -> thing.gid >=   value
comp.gid["lt"]    = comp.gid["<"]   = (thing, attrName, value) -> thing.gid <    value
comp.gid["lte"]   = comp.gid["<="]  = (thing, attrName, value) -> thing.gid <=   value

comp.attr["isa"]   = (thing, value) -> throw "ISA not defined for attr"
comp.attr["is"]    = comp.attr["="]   = (thing, attrName, value) -> thing.attr(attrName) is   value
comp.attr["isnt"]  = comp.attr["!="]  = (thing, attrName, value) -> thing.attr(attrName) isnt value
comp.attr["gt"]    = comp.attr[">"]   = (thing, attrName, value) -> thing.attr(attrName) >    value
comp.attr["gte"]   = comp.attr[">="]  = (thing, attrName, value) -> thing.attr(attrName) >=   value
comp.attr["lt"]    = comp.attr["<"]   = (thing, attrName, value) -> thing.attr(attrName) <    value
comp.attr["lte"]   = comp.attr["<="]  = (thing, attrName, value) -> thing.attr(attrName) <=   value

searchThing = (thing, selectors, args={}) ->
  args.one  ?= false
  args.soft ?= false

  # TODO: handle if selectors is a function (use deepChildrenByFunc from Thing)
  if utils.isFunction selectors
    selectors = [["passes", "function", selectors]]

  if utils.isNumber selectors
    selectors = [["gid", "is", selectors]]

  buildSelectorsFromString = (strSelectors, args) ->
    if matches = /^([0-9]+)$/.exec selectors
      return [["gid", "is", parseInt(matches[1])]]

    if matches = /^([A-Za-z0-9_\. ]+)$/.exec selectors
      if args.soft
        return [["name", "start", matches[1]]]
      else
        return [["name", "is", matches[1]]]

    if matches = /^([A-Za-z0-9_\. ]+)\[([A-Za-z0-9_]+)\]$/.exec selectors
      return [["name", "is", matches[1]], ["type", "isa", matches[2]]]

    if matches = /^\[([A-Za-z0-9_]+)\]$/.exec selectors
      return [["type", "isa", matches[1]]]

  # TODO - this needs to be much more general
  if utils.isString selectors
    # build the list of selectors to pass into the search algo
    selectors = buildSelectorsFromString selectors, args

  check = (thing, selectors) ->
    for selector in selectors
      [attr, relationship, value] = selector
      if attr in ["name", "type", "gid"]
        func = comp[attr][relationship]
      else
        func = comp["attr"][relationship]
      result = func thing, attr, value
      return false unless result
    true

  results = []
  search = (thing, selectors) ->
    if check thing, selectors
      results.push thing
    for gid, child of thing.children
      search child, selectors

  search thing, selectors

  return results[0] if results? and args.one
  return results

module.exports.searchThing = searchThing
