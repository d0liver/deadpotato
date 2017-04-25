{ObjectID}             = require 'mongodb'
{GraphQLScalarType}    = require 'graphql'
{makeExecutableSchema} = require 'graphql-tools'
Q                      = require 'q'
co                     = require 'co'
AWS                    = require 'aws-sdk'
Variant                = require './Variant'
Zip64VariantExtractor  = require './Zip64VariantExtractor'
ExtractorFilter        = require './ExtractorFilter'

SchemaBuilder = (db, user) ->
	variants = db.collection 'variants'
	games = db.collection 'games'

	MongoObjectID = new GraphQLScalarType
		name: 'ObjectID',
		description: 'Mongo ObjectID',
		serialize: (value) -> value.toString()
		parseValue: (value) ->
			try
				return ObjectID value
		parseLiteral: (ast) -> ast.value

	schema = """
		scalar ObjectID

		type Unit {
			type: String
			region: String
		}

		type Country {
			adjective: String
			capital_initial: String
			color: String
			name: String
			pattern: String
			supply_centers: [String]
			units: [Unit]
		}

		type Variant {
			_id: ObjectID!
			countries: [Country]
			name: String!
			map_data: String!
			season_year: String!
			slug: String!
		}

		type Player {
			pid: ID
			country: String
		}

		input GameArg {
			title: String!
			variant: String!
		}

		type Game {
			_id: ObjectID!
			title: String!
			variant: Variant
			player_country: String
			players: [Player]
		}

		type Query {
			variant(slug: String!): Variant
			variants: [Variant]
			game(_id: ObjectID!): Game
			games: [Game]
		}

		type Mutation {
			createVariant(variant: String!): ObjectID!
			createGame(game: GameArg): ObjectID!
			joinGame(country: String!, game: ObjectID!): String
		}
	"""

	findGame = co.wrap (_id) ->
		console.log "ID: ", _id
		game = yield games.findOne({_id})
		console.log "Game: ", game
		game.player_country = (game.players.find (player) -> player.pid is user?.id).country
		console.log "Game: ", game
		return game

	resolvers =
		ObjectID: MongoObjectID
		Mutation:
			createVariant: co.wrap (obj, {variant}) ->
				# TODO: Consider rate limiting or approving variant uploads.
				extractor = Zip64VariantExtractor variant
				variant_data = (Variant extractor).parse()

				# Check if the variant exists already
				if yield variants.findOne(slug: variant_data.slug)
					console.log "Variant already exists"
					return

				yield variants.insertOne variant_data

				console.log "Variant name is: ", variant_data.name
				AWS.config.loadFromPath "#{process.env.HOME}/.deadpotato_s3.json"

				f = ExtractorFilter variant_data
				filter = f.filter.bind(f)

				for {name, buff} from extractor.extract filter
					console.log "Uploading #{name} to S3..."
					params =
						Bucket: 'deadpotato'
						Key: name
						Body: buff
						ContentDisposition: 'inline'
						ContentType: 'image/bmp'
						ACL: 'public-read'

					s3 = new AWS.S3
					put = Q.denodeify s3.putObject.bind s3
					try
						yield put params
						console.log "Uploaded variant image successfully."
					catch err
						console.log "An error occurred while uploading the variant image: ", err

				return 'Success?'

			createGame: co.wrap (obj, {game}) ->
				{insertedId} = yield games.insertOne game
				return insertedId

			joinGame: co.wrap (obj, {game: _id, country}) ->
				# Make sure that this current hasn't already been selected
				available = ! yield games.findOne {_id, "players.country": country}
				console.log "Available? ", available
				if available
					yield games.update {_id}, $push: players: {country, pid: user.id}

		Query:
			variant: co.wrap (obj, {slug}) ->
				yield variants.findOne {slug}

			# Get a list of available variants
			variants: co.wrap (obj, {slug}) ->
				yield variants.find({}, {name: 1, _id: 1}).toArray()

			game: (obj, {_id}) -> findGame _id

			games: co.wrap ->
				yield games.find().toArray()

		Game:
			variant: co.wrap ({variant: _id}) ->
				yield variants.findOne {_id}


	return makeExecutableSchema {typeDefs: schema, resolvers}

module.exports = SchemaBuilder
