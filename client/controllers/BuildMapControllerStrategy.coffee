KeyboardInputHandler = require '../KeyboardInputHandler'

class BuildMapControllerStrategy

	constructor: (@_map_controller, @_map, @_board) ->
		orders = []
		Object.defineProperty @, 'orders', get: -> orders

		kiph = new KeyboardInputHandler
		@_map.on 'select', (selected) =>
			console.log "Selected: ", selected.id, "active: ", @_map.active[0]
			if @_map.active.length is 0
				@_map.select selected.id
			# Require a double click to build. The first click will just select
			# the region.
			else if @_map.active.length is 1 and selected.id is @_map.active[0]
				utype =
					if kiph.ctrlIsDown or kiph.shiftIsDown then 'Fleet'
					else 'Army'

				console.log "region: ", selected.id
				console.log "r1: ", @_board.region selected.id
				# TODO: Hard coded for the time being but should be our current
				# country.
				country = "Germany"
				orders.push "#{country}: Build #{utype[0]} #{@_map.active}"
				@_map.clearActive()
				@_map.setIcon selected.id, utype

module.exports = BuildMapControllerStrategy
