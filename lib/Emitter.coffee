Emitter = ->
	self = {}
	handlers = {}
	
	self.on = (evt, handler) ->
		handlers[evt] ?= []
		handlers[evt].push handler

	self.trigger = (name, _this, e) ->
		for handler in handlers[name]
			handler.call _this, e

	return self

module.exports = Emitter
