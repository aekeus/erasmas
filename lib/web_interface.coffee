class WebInterface
  constructor: (@world, @kernel) ->
    assert @world?
    assert @kernel?
    wi = this

    thingLink = (thing) ->
      "<a href='/Thing/#{thing.gid}'>#{thing}</a>"

    recurseThing = (thing, level = 0) ->
      if thing.isa("Character")
        buffer = "<a href='/Thing/#{thing.gid}'><b>#{thing}</b></a><br/>"
      else
        buffer = "<a href='/Thing/#{thing.gid}'>#{thing}</a><br/>"
      for gid, child of thing.children
        buffer += ("  " for x in [0..level]).join("") + recurseThing(child, level + 1)
      buffer

    styleLink = () -> "<link href=\"/style.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />"
    header = (title) -> "<html><head>#{styleLink()}<title>Commands</title></head><body>"

    web.get "/style.5Bcss", nr.staticHandler "static/style.css"

    web.get "/commands", (req, res) ->
      buffer  = "#{header('Commands')}<h1>Commands</h1><pre>"
      buffer += kernel.dispatcher.formattedCommands().join(utils.eol)
      buffer += "</pre></body></html>"
      buffer

    web.get "/tree", (req, res) ->
      buffer = "#{header('Object Tree')}<h1>World Tree</h1><pre>"
      buffer += recurseThing wi.world
      buffer += "</pre></body></html>"
      buffer

    web.get "/tree/([0-9]+)", (req, res) ->
      thing = registry.get(parseInt(gid))
      if thing?
        buffer = "<html><head><title>Sub-Tree</title></head><body><h1>Sub-Tree of #{thing}</h1><pre>"
        buffer += recurseThing thing
        buffer += "</pre></body></html>"
        buffer

    web.get "/tree/rep", (req, res) ->
      wi.world.fullRep()

    web.get new RegExp("^/Thing/(.*)/rep$"), (req, res, gid) ->
      thing = registry.get(parseInt(gid))
      if thing?
        thing.rep()

    web.get new RegExp("^/Thing/(.*)$"), (req, res, gid) ->
      buffer = header "Thing"
      thing = registry.get(parseInt(gid))
      if thing?
        buffer += "<a href=\"/tree\">tree</a> | Parent: <a href='/Thing/#{thing.parent?.gid}'>#{thing?.parent}</a><br/>"
        buffer += "<h1>#{thing.constructor.name} #{thing.mqname()} (#{thing.gid})</h1>"

        attrNames = thing.attrNames()
        if attrNames.length > 0
          buffer += "<h2>Attributes</h2><table class=\"attributes\"><tr><th>Key</th><th>Value</th></tr>"
          for k, v of thing.attributes
            destObj = registry.get(parseInt(v))
            if destObj?
              buffer += "<tr><td>#{k}</td><td>#{v} - #{thingLink destObj}</td><td>{Global Reference}</td></tr>"
            else
              buffer += "<tr><td>#{k}</td><td>#{v}</td><td>{#{utils.typeLabel v}}</td></tr>"
          buffer += "</table>"

        if thing.numberOfChildren() > 0
          buffer += "<h2>Children</h2><ul>"
          for k, v of thing.children
            buffer += "<li>#{thingLink v}</li>"
          buffer += "</ul>"

        if thing.interface?
          buffer += "<h2>Actions</h2><ul>"
          for k, v of thing.interface
            buffer += "<li>#{k}</li>"
          buffer += "</ul>"

        if thing.listeners?
          buffer += "<h2>Listeners</h2>"
          for k, v of thing.listeners
            buffer += "<li>#{thingLink v}</li>"
          buffer += "</ul>"

      buffer += "</body></html>"
      buffer

    web.listen 8080
