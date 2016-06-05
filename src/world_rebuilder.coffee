{ createable } = require './createable'
require './room'
require './playthings'
require './common_objects'
require './thing'
require './maze'
require './transports'
require './containers'
require './bots'

class WorldRebuilder
  constructor: (@json) ->

  build: ->
    builder = (node) ->
      creater = createable.byType(node.type)
      throw "#{node.type} not createable" unless creater?
      obj = new creater(node.name, node.attributes, node.gid)
      if node.children
        for gid, childNode of node.children
          obj.add(builder(childNode))
      return obj

    builder @json

module.exports =
  WorldRebuilder: WorldRebuilder
