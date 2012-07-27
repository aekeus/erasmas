# utility functions
utils =
  eol: "\r\n"

  prompt: "> "

  parse: (text) ->
    token = ""
    tokens = []
    inString = false

    for char in text
      if char is " "
        unless inString
          if token
            tokens.push token
            token = ""
        else
          token += char
      else
        if char is '"'
          inString = !inString
        else
          token += char
    tokens.push token if token
    tokens

  textForThings: (things, endSep = "or", emptyText = "") ->
    if things.length is 0
      emptyText
    else if things.length is 1
      things[0].mqname()
    else
      (thing.mqname() for thing in things[0..things.length - 2]).join(", ") + " #{endSep} " + things[things.length-1].mqname()

  pickOne: (list) ->
    list[Math.floor(Math.random() * list.length)]

  notFoundMsg: (gidName) ->
    "\"#{gidName}\" not found"

  # these are from CoffeeScript port of underscore library https://github.com/jashkenas/coffee-script/blob/master/examples/underscore.coffee
  isArray:    (obj) -> !!(obj and obj.concat and obj.unshift and not obj.callee)
  isRegExp:   (obj) -> !!(obj and obj.exec and (obj.ignoreCase or obj.ignoreCase is false))
  isString:   (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))
  isNumber:   (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
  isFunction: (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)

  trimQuotes: (match) ->
    match = match.replace /^\"+/, ""
    match = match.replace /\"+$/, ""
    match

  trim: (cmd) ->
    cmd = cmd.replace(/^[\s]+/, "")
    cmd = cmd.replace(/[\s]+$/, "")
    cmd

  repeat: (char, times) ->
    buffer = ""
    for i in [0..times]
      buffer += char
    buffer

  typeLabel: (v) ->
    if utils.isArray v
      "List"
    else if utils.isString v
      "String"
    else if utils.isNumber v
      "Number"
    else
      "Unknown"

  looksLikeInteger: (s) -> s.match(/^[0-9]+$/g)
  looksLikeFloat: (s) -> s.match(/^[0-9\.]+$/g)
  looksLikeNumber: (s) -> looksLikeFloat(s) or looksLikeInteger(s)

  clone: (thing) ->
    JSON.parse JSON.stringify thing

  parseValue: (v) ->
    switch v
      when "false"
        false
      when "true"
        true
      when "list"
        []
      else
        if utils.isString v
          if utils.looksLikeInteger v
            parseInt(v)
          else if utils.looksLikeFloat v
            parseFloat(v)
          else
            utils.trimQuotes v
        else
          v

