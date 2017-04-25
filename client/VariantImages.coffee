S3_BUCKET = "https://s3.us-east-2.amazonaws.com/deadpotato/"

VariantImages = (slug) ->
	self = {}
	self.map = -> "#{S3_BUCKET}#{slug}/map.bmp"

	return self

module.exports = VariantImages
