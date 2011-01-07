class TicketAgent extends Character
  constructor: ->
    super

  "buyticket": (character) ->
    if character.attr("money")? > 10
      "Ticket purchased"
    else
      "You do not have enough money to buy a ticket to " + registry.get(@attr("destination"))?.name

  interface:
    "buyticket": 1

CORE.TicketAgent = TicketAgent
