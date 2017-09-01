{Gavel, Board, PathFinder} = require process.env.HOME + '/gavel/'
{ObjectID} = require 'mongodb'

GameModel = (db) ->
	self = {}
	games = db.collection 'games'
	phases = db.collection 'phases'
	variants = db.collection 'variants'

	self.find = (_id) ->
		game = await games.findOne {_id}
		# console.log "Found variant? ", variant
		# playerIsCurrentUser = ({pid}) -> pid is user?.id
		# game.player_country = game.players.find(playerIsCurrentUser).country
		return game

	self.join = (_id, country) ->
		# Make sure that this current hasn't already been selected
		available = ! await games.findOne {_id, "players.country": country}
		if available
			await games.update {_id}, $push: players: {country, pid: user.id}

	self.create = (data) ->
		# Insert the game first so we can reference the inserted id below
		game = title: data.title
		{insertedId: gid} = await games.insertOne data

		# Find a template for this game (starting units and season)
		phase_template = await phases.findOne(variant: data.variant)

		# Create the first phase from the template
		phase = phase_template
		# We want to generate a new id, not use the one from the template
		delete phase._id
		phase.template = false
		phase.game = gid
		await phases.insertOne phase

		return gid

	self.list = (obj, {_id}) ->
		if _id?
			await games.find({_id}).toArray()
		else
			await games.find().toArray()

	# Do the things necessary to roll the game to the next phase
	self.roll = (_id) ->
		gdata = await games.findOne {_id}

		vdata = await variants.findOne {_id: gdata.variant}
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
		await games.updateOne {_id}, gdata

		return true

	return self

module.exports = GameModel