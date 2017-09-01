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

{parseOrder} = require 'gavel.js'

SchemaBuilder = (db, user, S3) ->
	phase     = PhaseModel db
	game      = GameModel db
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

		Query:
			variants: variantm.list
			games: game.list
			isAuthed: -> return Q user?

		Game:
			variant: ({variant: _id}) -> variants.findOne {_id}
			phase: ({_id}) -> phase.current _id

		VariantMutations:
			create: (obj, {variant: b64}) -> variantm.create(b64)

		GameMutations:
			join: (obj, {game: _id, country}) -> from game.join _id, country
			create: (obj, {game: data}) -> game.create data

		OrdersMutations:
			submit: (obj, {_id, orders}) ->
				# TODO: Need a way to overwrite submitted orders.
				await db.collection('games').updateOne {_id},
					'$push': orders: '$each': orders

				{orders, countries} = await db.collection('games').findOne {_id}, orders: 1, countries: 1
				countries = countries.map (c) -> c.name
				orders = (parseOrder order for order in orders)

				all_countries_have_orders = _.every countries, (country) ->
					orders.find (order) -> order.country is country

				if all_countries_have_orders
					await game.roll _id
				else
					console.log "Missing orders"

				Q null

	return makeExecutableSchema {typeDefs: schema, resolvers}

module.exports = SchemaBuilder
