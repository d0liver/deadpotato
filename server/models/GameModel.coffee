PhaseModel = require './PhaseModel'
{ObjectID} = require 'mongodb'

class GameModel
	constructor: (@_id, @_db, Gavel) ->
		@_games = @_db.collection 'games'
		@_phases = @_db.collection 'phases'
		@_variants = @_db.collection 'variants'

	# Constructor cannot be async
	init: ->
		{gdata, vdata} = await @joined @_id
		@_gavel = new Gavel gdata, vdata

	find: ->
		game = await @_games.findOne {_id}
		# console.log "Found variant? ", variant
		# playerIsCurrentUser = ({pid}) -> pid is user?.id
		# game.player_country = game.players.find(playerIsCurrentUser).country
		return game

	join: (country) ->
		# Make sure that this country hasn't already been selected
		available = ! await @_games.findOne {_id, "players.country": country}
		if available
			await @_games.update {@_id}, $push: players: {country, pid: user.id}

	@create = (data) ->
		# Insert the game first so we can reference the inserted id below
		game = title: data.title
		{insertedId: gid} = await @_games.insertOne data

		# Find a template for this game (starting units and season)
		phase_template = await @_phases.findOne(variant: data.variant)

		# Create the first phase from the template
		phase = phase_template
		# We want to generate a new id, not use the one from the template
		delete phase._id
		phase.template = false
		phase.roll_time = new Date()
		phase.game = gid
		await @_phases.insertOne phase

		return gid

	@list = (db, obj) -> await db.collection("games").find().toArray()

	list: (obj) -> await @_games.find({_id}).toArray()

	joined: (_id) ->
		gdata = await @_games.findOne {_id}
		current_phase = await (new PhaseModel @_db).current _id

		# TODO: The Gavel stuff expects this all to be on the same object.
		# Maybe it shouldn't?
		gdata.phase = current_phase

		vdata = await @_variants.findOne {_id: gdata.variant}
		vdata.map_data = JSON.parse vdata.map_data

		return {gdata, vdata}

	# Do the things necessary to roll the game to the next phase
	roll: (_id, orders) ->

		# Resolve and apply the result to the board
		@_gavel.roll orders

		# Update the game state. Clear out the orders and then update with the
		# game state after the board updates it.
		gdata.orders = []
		# Separate the phase data back out.
		gdata.phase.roll_time = new Date()
		gdata.phase.template = false
		gdata.phase.season_year = "#{@_gavel.phase}"
		delete gdata.phase._id
		await @_phases.insertOne gdata.phase

		return true

module.exports = GameModel
