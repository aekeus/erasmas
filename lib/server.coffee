class Server
  constructor: (@port, @timeout = 2) ->
    serv = this
    @connections = []
    @serv = tcp.createServer (socket) ->
      socket.setTimeout @timeout * 60 * 1000
      socket.setEncoding "utf8"
      connection = new Connection socket
      serv.connections.push connection

    @console = tcp.createServer (socket) ->
      socket.setTimeout @timeout * 60 * 1000
      socket.setEncoding "utf8"

  start: ->
    puts "Server started on port " + @port
    @serv.listen @port
    @console.listen 9000
