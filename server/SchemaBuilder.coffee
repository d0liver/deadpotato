{ObjectID}             = require 'mongodb'
{GraphQLScalarType}    = require 'graphql'
{makeExecutableSchema} = require 'graphql-tools'
Q                      = require 'q'
co                     = require 'co'
AWS                    = require 'aws-sdk'
schema                 = require './schema'
through                = require 'through2'
GameModel              = require './GameModel'
PhaseModel             = require './PhaseModel'
VariantModel           = require './VariantModel'
{UserException}        = require '../lib/Exceptions'
_                      = require 'underscore'

{parseOrder} = require '/home/david/gavel'

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
			game: -> Q {}
			variant: -> Q {}

		Query:
			variants: variantm.list
			games: game.list
			isAuthed: -> return Q user?

		Game:
			variant: ({variant: _id}) ->
				co ->
					yield variants.findOne {_id}
				.catch (err) ->
					console.log 'Could not find variant: ', err

			countries: ({_id}) ->
				co ->
					(yield phase.current _id).countries
				.catch (err) ->
					console.log 'Could not find country: ', err

		VariantMutations:
			create: (obj, {variant: b64}) -> variantm.create(b64)

		GameMutations:
			join: (obj, {game: _id, country}) -> from game.join _id, country
			create: (obj, {game: data}) -> game.create data

		OrdersMutations:
			submit: (obj, {_id, orders}) ->
				# TODO: Need a way to overwrite submitted orders.
				yield db.collection('games').updateOne {_id},
					'$push': orders: '$each': orders

				{orders, countries} = yield db.collection('games').findOne {_id}, orders: 1, countries: 1
				countries = countries.map (c) -> c.name
				orders = (parseOrder order for order in orders)

				all_countries_have_orders = _.every countries, (country) ->
					orders.find (order) -> order.country is country

				if all_countries_have_orders
					yield game.roll _id
				else
					console.log "Missing orders"

				Q null

	# Wrap each of our resolvers with error handling logic (format an
	# appropriate response)
	for type,val of resolvers when val not instanceof GraphQLScalarType
		for name,fu of resolvers[type]
			do (fu) ->
				resolvers[type][name] = co.wrap (args...) ->
					try
						return yield fu(args...)
					catch err
						console.log err
						if err instanceof UserException
							throw err
						else
							throw new Error('Internal server error.')

	return makeExecutableSchema {typeDefs: schema, resolvers}

module.exports = SchemaBuilder
