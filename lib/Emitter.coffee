Emitter = ->
	self = {}
	handlers = {}
	
	self.on = (evt, handler) ->
		handlers[evt] ?= []
		handlers[evt].push handler

	self.trigger = (name, e) ->
		handler e for handler in handlers[name]

	return self

module.exports = Emitter
