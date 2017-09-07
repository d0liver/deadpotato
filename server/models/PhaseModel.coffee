class PhaseModel
	phases = null

	constructor: (db) ->
		phases = db.collection 'phases'

	current: (game_id) ->
		[phase] = await phases.find(game: game_id).sort(roll_time: -1).limit(1).toArray()
		return phase

module.exports = PhaseModel
