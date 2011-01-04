class Console
  constructor: (@socket) ->
    return unless @socket
    log "Console accepted from " + socket.remoteAddress
    buffer = ""

    socket.addListener "data", (packet) ->
      try
        buffer += packet
        i = buffer.indexOf("\r\n")
        while i isnt -1
          message = buffer.slice 0, i
          if message.length > 512
            conn.quit "flooding"
          else if message.length is 0
            "return only - ignore"
          else
            tokens = conn.parse message
            kernel.handleInput conn, tokens, "#{message}"
          buffer = buffer.slice i + 2
          i = buffer.indexOf("\r\n")
      catch error
        puts "Uncaught exception! " + error

    socket.addListener "eof", (packet) ->
      try
        conn.quit("connection reset by peer")
      catch error
        puts "Uncaught exception! " + error

    socket.addListener "timeout", (packet) ->
      try
        conn.quit("idle timeout")
      catch error
        puts "Uncaught exception! " + error

  send: (text) ->
    @socket.write(text + utils.eol + utils.prompt) if @socket?
