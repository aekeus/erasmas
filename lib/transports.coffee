class TicketAgent extends Character
  constructor: ->
    super
    @attr("cost", 1) unless @attr("cost")?

  doorName: ->
    registry.get(@attr("door"))?.name || 'unknown'

  "buyTicket": (character) ->
    if character.attr("money") || 0 > @attr("cost")
      character.attr "money", character.attr("money") - @attr("cost")
      ticket = new Ticket "Ticket to " + @doorName(),
        door: @attr('door')
      character.add ticket
      "Ticket purchased via " + @doorName()
    else
      "You do not have enough money to buy a ticket via " + registry.get(@attr("door"))?.name

  interface:
    "buy-ticket": 1

CORE.TicketAgent = TicketAgent

class Ticket extends Thing
  constructor: ->
    super

  door: -> @attr("door")

CORE.Ticket = Ticket

class TicketDoor extends Door
  constructor: ->
    super

  canTraverse: (character) ->
    tickets = character.search "[Ticket]"
    for ticket in tickets
      return true if ticket.attr("door") is @gid
    false

CORE.TicketDoor = TicketDoor

