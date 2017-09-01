PhaseModel = (db) ->
	self = {}
	phases = db.collection 'phases'

	self.current = (game_id) ->
		[phase] = await phases.find(game: game_id).limit(1).sort(roll_time: -1).toArray()
		return phase

	return self

module.exports = PhaseModel
