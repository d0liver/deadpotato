{ObjectID}             = require 'mongodb'
{GraphQLScalarType}    = require 'graphql'
{makeExecutableSchema} = require 'graphql-tools'
Q                      = require 'q'
co                     = require 'co'
AWS                    = require 'aws-sdk'
Variant                = require './Variant'
Zip64VariantExtractor  = require './Zip64VariantExtractor'
VariantAssetExtractor  = require './VariantAssetExtractor'
schema                 = require './schema'

SchemaBuilder = (db, user) ->
	variants = db.collection 'variants'
	game = Game(db.collection('games'))

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
			'variant.create': (obj, {variant}) -> variantm.create variant
			'game.create': (obj, {game}) -> game.create(game)
			'game.join': (obj, {game: _id, country}) -> game.join _id, country

		Query:
			'variant.find': (obj, {slug}) -> variantm.find(slug)
			'variant.list': variantm.list
			game: (obj, {_id}) -> game.find(_id)
			'game.list': game.list()

		Game:
			variant: co.wrap ({variant: _id}) ->
				yield variants.findOne {_id}


	return makeExecutableSchema {typeDefs: schema, resolvers}

module.exports = SchemaBuilder
