fs            = require 'fs'
path          = require 'path'
puts          = require("sys").puts
{spawn, exec} = require 'child_process'

srcfiles = [
  'lib/preamble.coffee',
  'lib/msg.coffee',
  'lib/dispatch.coffee',
  'lib/event.coffee',
  'lib/world_rebuilder.coffee',
  'lib/web_interface.coffee',
  'lib/utils.coffee',
  'lib/registry.coffee',
  'lib/events.coffee',
  'lib/thing.coffee',
  'lib/search.coffee',
  'lib/playthings.coffee',
  'lib/common_objects.coffee',
  'lib/containers.coffee',
  'lib/room.coffee',
  'lib/character.coffee',
  'lib/transports.coffee',
  'lib/bots.coffee',
  'lib/door.coffee',
  'lib/connection.coffee',
  'lib/server.coffee',
  'lib/world.coffee',
  'lib/maze.coffee',
  'lib/kernel.coffee'
];

driverFiles = [
  'lib/driver.coffee'
];

testFiles = [
  'lib/test.coffee',
  'lib/tests.coffee'
];

task 'build', 'build the MUSH from source', ->
  command = 'cat ' + srcfiles.concat(driverFiles).join(" ") + ' > mush.coffee';
  exec command
  exec 'coffee -c mush.coffee'

task 'run', 'execute the MUSH', ->
  exec 'coffee mush.coffee', (err, stdout, stderr) ->
    console.log stdout.trim() if stdout
    console.log stderr.trim() if stderr
    throw err if err

task 'test', 'test the MUSH system', (options) ->
  exec 'cat ' + srcfiles.concat(testFiles).join(" ") + " > mush.test.coffee"
  exec 'coffee mush.test.coffee', (err, stdout, stderr) ->
    console.log stdout.trim() if stdout
    console.log stderr.trim() if stderr
    throw err    if err

task 'clean', 'clean up', ->
  exec 'rm mush.coffee'
  exec 'rm mush.js'
  exec 'rm mush.test.coffee'
  exec 'rm mush.test.js'
  exec 'rm lib/*.coffee~'
