class SubscriptionRegistry
  constructor: () ->
    @subscriptions = []

  notifySubscribers: (eventType, evt) ->
    for subscription in @subscriptions
      if subscription.eventType == eventType and subscription.subscriber isnt evt.source
        subscription.handler.call subscription.subscriber, evt

  add: (subscriber, eventType, handler) ->
    @subscriptions.push new Subscription(subscriber, eventType, handler)

  remove: (subscriber, eventType) ->
    lst = []
    for subscription in @subscriptions
#      debug "#{subscription.subscriber.name} compare #{subscriber.name}, #{subscription.eventType} compare #{eventType}"
      if subscription.subscriber == subscriber and subscription.eventType == eventType
#        debug "removing"
      else
#        debug "keeping"
        lst.push subscription
    @subscriptions = lst

  debug: () ->
    debug "\n\nSubscribers for '#{this.name}'"
    for subscription in @subscriptions
      subscription.debug()
    debug "\n"

class Subscription
  constructor: (@subscriber, @eventType, @handler) ->

  debug: () ->
    debug "#{this.eventType} - #{this.subscriber.name} - #{this.subscriber.name}"

