{ Thing } = require './thing'
{ utils } = require './utils'
{ Event } = require './event'
{ createable } = require './createable'
{ registry } = require './registry'

assert = require 'assert'
debug = console.log

#
#  Represents a Thing that can be connected to an input/output socket, can receive and send messages and interact
#  with its environment
#
class Character extends Thing
  constructor: () ->
    super

  connect: (connection) ->
    throw "already connected" if @connection?
    @connection = connection

  disconnect: ->
    @connection = null

  enterRoom: (room) ->
    room.add this
    return @look()

  leaveRoom: (room) ->
    room.remove this

  goThrough: (door) ->
    # sometimes we get a null here, lets trap for it
    return '' unless door?
    assert door.isa("Door"), "door must be a Door"

    return "That door does not exist. You can go " + utils.textForThings(this.siblingsOfType("Door")) unless door?.isa("Door")
    return "You cannot go that way"                                                                   unless door.canTraverse(this)
    destinationRoom = registry.get(door.destination())
    return "The destination room does not exist. Something is wrong with the world. hmm...."          unless destinationRoom?.isa("Room")

    this.leaveRoom this.parent
    this.enterRoom destinationRoom

  hear: (evt) ->
    if @connection?
      switch evt.type
        when "talk"
          @send "#{evt.source.mqname()} says \"#{evt.contents.words}\""
        when "remove"
          @send "#{evt.contents.thing.mqname()} has left"
        when "add"
          @send "#{evt.contents.thing.mqname()} has entered"
        else
          debug "character #{this} does not know what to do with event type #{evt.type}"

  look: () ->
    room = this.parent
    otherCharacters = this.siblingsOfType("Character")
    msg =
      if otherCharacters.length is 0
        "You are alone in #{room.mqname()}"
      else if otherCharacters.length is 1
        "You are in #{room.mqname()} with one other person (#{otherCharacters[0].mqname()})"
      else
        characterNames = utils.textForThings(otherCharacters, "and")
        "You are in #{room.mqname()} with #{otherCharacters.length} other people (#{characterNames})"

    msg += utils.eol
    msg += room.attr("description") + utils.eol if room.attr("description")?

    doors = room.doors()
    if doors.length > 0
      msg += "You can go " + utils.textForThings(doors, "or")
    else
      msg += "There are no exits from this room!"

    otherThings = (thing for gid, thing of this.parent.children when not thing.isa("Door") and not thing.isa("Character"))
    if otherThings.length > 0
      msg += utils.eol
      msg += "You see a " + utils.textForThings(otherThings, "and a")

    msg

  rename: (newName) ->
    this.tell "talks",
      "words": "I am changing my name to #{newName}"
      "source": this
    @name = newName
    this.sendIfConnected "You change your name to #{this.mqname()}"

  speak: (words) ->
    this.broadcast new Event "talk", this, "words": words

  password: ->
    this.attr("password")

  sendIfConnected: (msg) ->
    @connection.send(msg) if @connection?

  send: (msg) ->
    @connection.send(msg)

class PlayerCharacter extends Character
  constructor: () ->
    super

class NPC extends Character
  constructor: () ->
    super

inter =
  PlayerCharacter: PlayerCharacter
  Character: Character
  NPC: NPC

createable.addObject inter

module.exports = inter
