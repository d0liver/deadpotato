{ObjectID}             = require 'mongodb'
{GraphQLScalarType}    = require 'graphql'
{makeExecutableSchema} = require 'graphql-tools'
Q                      = require 'q'
co                     = require 'co'
AWS                    = require 'aws-sdk'
schema                 = require './schema'
through                = require 'through2'
Game                   = require './Game'
VariantModel           = require './VariantModel'
{UserException}        = require '../lib/Exceptions'
_                      = require 'underscore'

{parseOrder} = require '/home/david/gavel'

SchemaBuilder = (db, user, S3) ->
	game      = Game db
	variantm  = VariantModel db, S3
	variants = db.collection 'variants'

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
			createVariant: (obj, {variant: b64}) -> variantm.create(b64)
			createGame: (obj, {game: data}) -> game.create(data)
			joinGame: (obj, {game: _id, country}) -> game.join _id, country
			submitOrders: (obj, {_id, orders}) ->

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

		Query:
			findVariant: (obj, {slug}) -> variantm.find(slug)
			listVariants: variantm.list
			findGame: (obj, {_id}) -> game.find _id
			listGames: game.list
			isAuthed: -> return Q user?

		Game:
			variant: ({variant: _id}) ->
				co ->
					result = yield variants.findOne {_id}

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
