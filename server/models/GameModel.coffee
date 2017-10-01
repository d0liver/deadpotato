PhaseModel = require './PhaseModel'
{Gavel, Board, PathFinder} = require 'gavel.js'
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
		phase.roll_time = new Date()
		phase.game = gid
		await phases.insertOne phase

		return gid

	self.list = (obj, {_id}) ->
		if _id?
			await games.find({_id}).toArray()
		else
			await games.find().toArray()

	# Do the things necessary to roll the game to the next phase
	self.roll = (_id, orders) ->
		gdata = await games.findOne {_id}
		current_phase = await (new PhaseModel db).current _id
		# TODO: The Gavel stuff expects this all to be on the same object.
		# Maybe it shouldn't?
		gdata.phase = current_phase
		gdata.orders = orders
		console.log "GDATA: ", gdata

		vdata = await variants.findOne {_id: gdata.variant}
		vdata.map_data = JSON.parse vdata.map_data

		board   = Board gdata, vdata
		pfinder = new PathFinder board
		gavel   = new Gavel board, pfinder, gdata.phase.season_year

		# Resolve and apply the result to the board
		gavel.roll orders

		# Update the game state. Clear out the orders and then update with the
		# game state after the board updates it.
		gdata.orders = []
		# Separate the phase data back out.
		gdata.phase.roll_time = new Date()
		gdata.phase.template = false
		gdata.phase.season_year = "#{gavel.phase}"
		delete gdata.phase._id
		await phases.insertOne gdata.phase

		return true

	return self

module.exports = GameModel
