co = require 'co'

PhaseModel = (db) ->
	self = {}
	phases = db.collection 'phases'

	self.current = (game_id) ->
		co ->
			[phase] = yield phases.find(game: game_id).limit(1).sort(roll_time: -1).toArray()
			return phase
		.catch (err) ->
			console.log "An error occurred while attempting to fetch the current phase: ", err

	return self

module.exports = PhaseModel
