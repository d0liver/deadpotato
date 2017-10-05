{ObjectID}             = require 'mongodb'
{GraphQLScalarType}    = require 'graphql'
{makeExecutableSchema} = require 'graphql-tools'
AWS                    = require 'aws-sdk'
schema                 = require './schema'
through                = require 'through2'
GameModel              = require './models/GameModel'
PhaseModel             = require './models/PhaseModel'
VariantModel           = require './models/VariantModel'
{UserException}        = require '../lib/Exceptions'
_                      = require 'underscore'
{parseOrder, Gavel} = require 'gavel.js'

SchemaBuilder = (db, user, S3) ->
	phase     = new PhaseModel db

	variantm  = VariantModel db, S3
	variants  = db.collection 'variants'

	MongoObjectID = new GraphQLScalarType
		name: 'ObjectID',
		description: 'Mongo ObjectID',
		serialize: (value) -> value.toString()
		parseValue: (value) ->
			try
				return ObjectID value
		parseLiteral: (ast) -> ast.value

	resolvers =
		ObjectID: MongoObjectID
		Mutation:
			game: -> {}
			variant: -> {}
			order: -> {}

		Query:
			variants: variantm.list
			games: (o) -> GameModel.list db, o
			isAuthed: -> return Q user?

		Game:
			variant: ({variant: _id}) -> variants.findOne {_id}
			phase: ({_id}) -> phase.current _id

		VariantMutations:
			create: (obj, {variant: b64}) -> variantm.create(b64)

		GameMutations:
			join: (obj, {game: _id, country}) ->
				gm = new GameModel _id, db, Gavel
				await gm.init()
				await gm.join country

			create: (obj, {game: data}) -> GameModel.create data

		OrderMutations:
			submit: (obj, {_id, orders}) ->

				# Wrap the orders in an object so we can store some metadata on them.
				orders = {orders}

				# TODO: Remove any old orders for this country
				# await db.collection('orders').remove ...

				# Create and insert the new orders and attach them to the
				# current phase
				current_phase = await phase.current _id
				orders.phase = current_phase._id
				# Suggested orders will have a suggester and a suggestee
				await db.collection('orders').insert orders

				# Grab all of the orders for the current phase
				orders = await db.collection('orders').find({phase: current_phase._id}).toArray()
				# Pluck the orders out of the orders objects
				orders = orders.map (o) -> o.orders
				# Flatten and orders for easier traversal
				orders = (order for order in Array::concat orders...)
				countries = current_phase.countries.map (c) -> c.name
				gm = new GameModel _id, db, Gavel
				await gm.init()
				await gm.roll orders

				# all_countries_have_orders = _.every countries, (country) ->
				# 	orders.find (order) -> parseOrder(order).country is country

				# if all_countries_have_orders
				# 	await game.roll _id, orders
				# else
				# 	console.log "Missing orders"

				return null

	return makeExecutableSchema {typeDefs: schema, resolvers}

module.exports = SchemaBuilder
