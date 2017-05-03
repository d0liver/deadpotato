VariantModel = ->
	self = {}

	self.create = co.wrap (variant) ->
		co.wrap (obj, {variant}) ->
		# TODO: Consider rate limiting or approving variant uploads.
		extractor = Zip64VariantExtractor variant
		variant_data = (Variant extractor).parse()

		# Check if the variant exists already
		if yield variants.findOne(slug: variant_data.slug)
			console.log "Variant already exists"
			return

		console.log "Variant name is: ", variant_data.name
		AWS.config.loadFromPath "#{process.env.HOME}/.deadpotato_s3.json"

		vae = VariantAssetExtractor variant_data, extractor
		variant_data.standard_icons = ! vae.hasIcons()

		yield variants.insertOne variant_data

		return 'Success?'

	self.find = co.wrap (slug) -> yield variants.findOne {slug}

	# Get a list of available variants
	self.list = co.wrap ->
		yield variants.find({}, {name: 1, _id: 1}).toArray()

	return self

module.exports = VariantModel
