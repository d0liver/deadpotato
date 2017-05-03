co                                            = require 'co'
through                                       = require 'through2'
{S3UploadException, VariantValidateException} = require './Exceptions'
Zip64VariantExtractor                         = require './Zip64VariantExtractor'
VariantAssetExtractor                         = require './VariantAssetExtractor'
parseVariant                                  = require './parseVariant'
AWS                                           = require 'aws-sdk'
Q                                             = require 'q'
path                                          = require 'path'

VariantModel = (variants, S3) ->
	self = {}

	self.create = co.wrap (b64) ->
		s3 = new AWS.S3
		AWS.config.loadFromPath "#{process.env.HOME}/.deadpotato_s3.json"
		s3put = Q.denodeify s3.putObject.bind s3

		# TODO: Consider rate limiting or approving variant uploads.
		extractor      = Zip64VariantExtractor b64
		variant_data = yield parseVariant extractor.extract()
		asset_extractor = VariantAssetExtractor variant_data

		# Check if the variant exists already
		if yield variants.findOne(slug: variant_data.slug)
			msg = "A variant with the same name already exists."
			return new VariantValidateException msg

		# Upload all assets to s3 and store a list of these uploaded assets on
		# the variant_data so that the frontend can fall back accordingly for
		# assets which were not uploaded without extra http requests.
		variant_data.assets = []
		def = Q.defer()
		extractor.extract()
		.pipe asset_extractor.extract()
		.on 'data', (file) ->
			# We don't need to check for valid extensions because the asset
			# extractor does that already.
			ext = path.extname file.relative
			console.log "Uploading file: ", file.relative
			try
				s3put 
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

		.on 'end', def.resolve

		yield def.promise

		{insertedId} = yield variants.insertOne variant_data

		return insertedId

	self.find = co.wrap (slug) -> yield variants.findOne {slug}

	# Get a list of available variants
	self.list = co.wrap ->
		results = yield variants.find({}, {name: 1, _id: 1}).toArray()
		console.log "RESULTS: ", results
		return results

	return self

module.exports = VariantModel
