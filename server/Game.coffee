{ObjectID} = require 'mongodb'
co         = require 'co'

Game = (db) ->
	self = {}
	games = db.collection 'games'
	variants = db.collection 'variants'

	self.find = co.wrap (_id) ->
		game = yield games.findOne {_id}
		# console.log "Found variant? ", variant
		# playerIsCurrentUser = ({pid}) -> pid is user?.id
		# game.player_country = game.players.find(playerIsCurrentUser).country
		return game

	self.join = co.wrap (_id, country) ->
		# Make sure that this current hasn't already been selected
		available = ! yield games.findOne {_id, "players.country": country}
		if available
			yield games.update {_id}, $push: players: {country, pid: user.id}

	self.create = co.wrap (data) ->
		try
			data.variant = ObjectID data.variant
			{insertedId} = yield games.insertOne data
			return insertedId
		catch
		# TODO: What's the best thing to do here?

	self.list = co.wrap ->
		games = yield games.find().toArray()
		# for game in games
		# 	game.variant = yield variants.findOne _id: game.variant
		return games

	return self

module.exports = Game
