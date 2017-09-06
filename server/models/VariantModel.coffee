through                                       = require 'through2'
{S3UploadException, VariantValidateException} = require '../../lib/Exceptions'
Zip64VariantExtractor                         = require '../Zip64VariantExtractor'
VariantAssetExtractor                         = require '../VariantAssetExtractor'
parseVariant                                  = require '../parseVariant'
AWS                                           = require 'aws-sdk'
path                                          = require 'path'

VariantModel = (db, S3) ->
	self = {}
	variants = db.collection 'variants'
	phases = db.collection 'phases'

	self.create = (b64) ->
		AWS.config.loadFromPath "#{process.env.HOME}/.deadpotato_s3.json"
		s3 = new AWS.S3
		s3put = (obj) ->
			new Promise (resolve, reject) ->
				s3.putObject obj, (err, data) ->
					unless err? then resolve data
					else reject err

		# TODO: Consider rate limiting or approving variant uploads.
		extractor      = Zip64VariantExtractor b64
		variant_data = await parseVariant extractor.extract()
		asset_extractor = VariantAssetExtractor variant_data

		# Check if the variant exists already
		if await variants.findOne(slug: variant_data.slug)
			msg = "A variant with the same name already exists."
			throw new VariantValidateException msg

		# Upload all assets to s3 and store a list of these uploaded assets on
		# the variant_data so that the frontend can fall back accordingly for
		# assets which were not uploaded without extra http requests.
		variant_data.assets = []
		await new Promise (resolve, reject) ->
			extractor.extract()
			.pipe asset_extractor.extract()
			.on 'data', (file) ->
				# We don't need to check for valid extensions because the asset
				# extractor does that already.
				ext = path.extname file.relative
				console.log "Uploading file: ", file.relative
				try
					await s3put 
						Bucket: 'deadpotato'
						Key: file.relative
						Body: file.contents
						ContentDisposition: 'inline'
						ContentType: "image/#{ext[1..]}"
						ACL: 'public-read'
					variant_data.assets.push file.relative
				catch
					msg = "We are currently having difficulty accessing our storage
					servers. Please try again later."
					throw new S3UploadException msg

			.on 'end', resolve

		# Split out the stuff that's actually variant data and doesn't change
		# from the stuff that should be part of the game state. Then insert
		# both.
		vdata =
			name: variant_data.name
			map_data: variant_data.map_data
			slug: variant_data.slug
			assets: variant_data.assets

		{insertedId} = await variants.insertOne vdata

		phase_data =
			countries: variant_data.countries
			season_year: variant_data.season_year
			template: true
			variant: insertedId

		{insertedId} = await phases.insertOne phase_data

		return insertedId

	self.find = (slug) -> variants.findOne {slug}

	# Get a list of available variants
	self.list = ->
		variants.find({}, {name: 1, _id: 1}).toArray()

	return self

module.exports = VariantModel
