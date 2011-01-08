class Dispatcher
  constructor: () ->
    @cmds = []

  install: (func, desc, tokens...) ->
    specs =
      S:           "(?:\\s+)"
      ID:          "([\\w\\d ]+\\[[\\w\\d]+\\]|[\\d]+|[\\w ]+|\\\"[\\w ]+\\\")"
#      ALPHANUM:    "([\\[\\]\\w\\d\\.\\/]+|\\\"[\\[\\]\\w\\d\\. \\/]+\\\")"
      CLS:         "([\\w\\d]+)"
      ALPHANUM:    "(.+|\\\".+\\\")"

    strRegex = (specs[tok] || tok for tok in tokens).join(specs.S)
    @installRegex func, new RegExp(strRegex, "gi"), desc, tokens

  installRegex: (func, regex, desc, tokens) ->
    @cmds.push [regex, func, desc, tokens]

  method: (conn, cmd) ->
    cmd = utils.trim cmd
    for cmdSpec in @cmds
      [regex, func, desc] = cmdSpec
      regex.exec ""
      matches = regex.exec cmd
      if matches
        matches = (utils.trimQuotes match for match in matches)
        return [func, matches[1..]]

  dispatch: (conn, cmd) ->
    [func, matches] = this.method(conn, cmd)
    if func
      return func.apply(null, [conn].concat(matches))

  formattedCommands: ->
    maxCommand = maxDescription = 0
    buffer = []

    for spec in @cmds
      cmd = spec[3].join(" ")
      maxCommand     = cmd.length if cmd.length > maxCommand
      maxDescription = spec[2].length if spec[2].length > maxDescription

    for spec in @cmds
      cmd = spec[3].join(" ")
      buffer.push cmd + " " + utils.repeat(" ", maxCommand - cmd.length) + "#{spec[2]}"

    buffer
