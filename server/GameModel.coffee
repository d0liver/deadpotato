{Gavel, Board, PathFinder} = require '/home/david/gavel/'
{ObjectID} = require 'mongodb'
co         = require 'co'

GameModel = (db) ->
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
			# Find a template for this game (starting units and season)
			if template = yield games.findOne(variant: data.variant)
				delete template._id
				data = Object.assign {}, template, data
				data.template = false
				{insertedId} = yield games.insertOne data
				return insertedId
		catch
		# TODO: What's the best thing to do here?

	self.list = (obj, {_id})->
		co ->
			unless _id?
				yield games.find(template: false).toArray()
			else
				console.log "HERE? "
				yield games.find({_id}).toArray()
		.catch (err) ->
			console.log "Could not retrieve games list."

	# Do the things necessary to roll the game to the next phase
	self.roll = co.wrap (_id) ->
		gdata = yield games.findOne {_id}

		vdata = yield variants.findOne {_id: gdata.variant}
		vdata.map_data = JSON.parse vdata.map_data
		
		board   = Board gdata, vdata
		pfinder = PathFinder board
		gavel  = Gavel board, pfinder

		[phase, year] = gdata.season_year.split /\s+/
		gavel.setPhase phase; gavel.setYear year
		# Resolve and apply the result to the board
		gavel.apply gdata.orders

		# Update the game state. Clear out the orders and then update with the
		# game state after the board updates it.
		gdata.orders = []
		console.log "SAVE GDATA AFter: ", JSON.stringify gdata, null, 4
		yield games.updateOne {_id}, gdata

		return true

	return self

module.exports = GameModel
