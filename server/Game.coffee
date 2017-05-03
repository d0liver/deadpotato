Game = (games) ->
	self = {}

	self.find = co.wrap (_id) ->
		game = yield games.findOne({_id})
		playerIsCurrentUser = ({pid}) -> pid is user?.id
		game.player_country = game.players.find(playerIsCurrentUser).country
		return game

	self.join = co.wrap (_id, country) ->
		console.log "JOING GAME: , id: ", _id, "country: ", country
		# Make sure that this current hasn't already been selected
		available = ! yield games.findOne {_id, "players.country": country}
		console.log "Available? ", available
		if available
			yield games.update {_id}, $push: players: {country, pid: user.id}

	self.create = co.wrap (game) ->
		{insertedId} = yield games.insertOne game
		return insertedId

	self.list = co.wrap -> yield games.find().toArray()

	return self

module.exports = Game
