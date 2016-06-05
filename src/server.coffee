{ Connection } = require './connection'
assert = require 'assert'

tcp = require 'net'

class Server
  constructor: (@port, @timeout = 2, kernel) ->
    assert kernel, "kernel defined"
    serv = @
    @connections = []
    @serv = tcp.createServer (socket) ->
      # socket.setTimeout @timeout * 60 * 1000
      socket.setEncoding "utf8"
      connection = new Connection socket, kernel
      serv.connections.push connection

    @console = tcp.createServer (socket) ->
      # socket.setTimeout @timeout * 60 * 1000
      socket.setEncoding "utf8"

  start: ->
    console.log "Server started on port " + @port
    @serv.listen @port
    @console.listen 9000

module.exports.Server = Server
