{ObjectID}             = require 'mongodb'
{GraphQLScalarType}    = require 'graphql'
{makeExecutableSchema} = require 'graphql-tools'
Q                      = require 'q'
co                     = require 'co'
AWS                    = require 'aws-sdk'
slug                   = require 'slug'
Variant                = require './Variant'
Zip64VariantExtractor  = require './Zip64VariantExtractor'

SchemaBuilder = (db) ->

	schema = """
		type Mutation {
			createVariant(variant: String!): String!
		}

		type Query {
			derp: String
		}
	"""

	resolvers =
		Mutation:
			createVariant: co.wrap (obj, {variant}) ->
				variants = db.collection 'variants'
				# TODO: Consider rate limiting or approving variant uploads.
				extractor = Zip64VariantExtractor variant
				variant_info = (Variant extractor).parse()
				slg = slug variant_info.name

				# Check if the variant exists already
				if yield variants.findOne(slug: slg)
					console.log "Variant already exists"
					return

				yield variants.insertOne Object.assign slug: slg, variant_info

				console.log "Uploading variant image file to S3..."
				console.log "Variant name is: ", variant_info.name
				AWS.config.loadFromPath "#{process.env.HOME}/.deadpotato_s3.json"
				params =
					Bucket: 'deadpotato'
					Key: slg+".bmp"
					Body: extractor.image()
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
		Query:
			derp: ->

	return makeExecutableSchema {typeDefs: schema, resolvers}

module.exports = SchemaBuilder
