class WorldRebuilder
  constructor: (@json) ->

  build: ->
    builder = (node) ->
      obj = new CORE[node.type](node.name, node.attributes, node.gid)
      if node.children
        for gid, childNode of node.children
          obj.add(builder(childNode))
      return obj

    builder @json

