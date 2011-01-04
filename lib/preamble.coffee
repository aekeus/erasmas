tcp  = require("net")
puts = require("sys").puts
fs   = require("fs")
web  = require('./lib/node-router').getServer();

QUIET = false
debug = (text) ->
  puts "DEBUG: #{text}" if not QUIET

assert = (bool, text = "") ->
  throw "assert failed - #{text}" unless bool

mAssert = () ->
  for arg in arguments
    throw "assert failed" unless arg

# namespaces
CORE = {}
