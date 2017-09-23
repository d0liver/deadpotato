class BuildMapControllerStrategy

	constructor: (@_map_controller, @_map, @_board) ->
		console.log "Init build controls?"
		@_map.on 'select', =>
			console.log "Select fired!!"

module.exports = BuildMapControllerStrategy
