class Dispatcher
  constructor: () ->
    @cmds = []

  #
  #  Install a command handler from a list of tokens
  #
  #  func   - function handler                        {Function}
  #  desc   - description of the command              {String}
  #  tokens - list of tokens (may be handler tokens}  {Array of String}
  #
  install: (func, desc, tokens...) ->
    specs =
      S:           "(?:\\s+)"
      ID:          "([\\w\\d ]+\\[[\\w\\d]+\\]|[\\d]+|[\\w ]+|\\\"[\\w ]+\\\")"
#      ALPHANUM:    "([\\[\\]\\w\\d\\.\\/]+|\\\"[\\[\\]\\w\\d\\. \\/]+\\\")"
      CLS:         "([\\w\\d]+)"
      ALPHANUM:    "(.+|\\\".+\\\")"

    strRegex = (specs[tok] || tok for tok in tokens).join(specs.S)
    @installRegex func, new RegExp(strRegex, "gi"), desc, tokens

  #
  #  Install a regular expression handler for a text command
  #
  #  func   - function reference                    {Function}
  #  regex  - Regular express with matching groups  {Regex}
  #  desc   - description of the command            {String}
  #  tokens - list of tokens                        {String}
  #
  installRegex: (func, regex, desc, tokens) ->
    @cmds.push [regex, func, desc, tokens]

  #
  #  Retrieve a function reference based on the cmd
  #
  #    conn - user connection {Connection}
  #    cmd  - raw text        {String}
  #
  #  Returns
  #
  #    [function, array of matching elements]
  #
  method: (conn, cmd) ->
    cmd = utils.trim cmd
    for cmdSpec in @cmds
      [regex, func, desc] = cmdSpec
      regex.exec ""
      matches = regex.exec cmd
      if matches
        matches = (utils.trimQuotes match for match in matches)
        return [func, matches[1..]]
    [null, null]

  #
  #  Retrieve and execute a function based on the raw input from a user connection
  #
  #    conn - user connection {Connection}
  #    cmd  - raw text        {String}
  #
  dispatch: (conn, cmd) ->
    [func, matches] = this.method(conn, cmd)
    if func
      return func.apply(null, [conn].concat(matches))
    else
      "Invalid command"

  #
  #  Generate a formatted list of valid commands
  #
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
