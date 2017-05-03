Zip  = require 'node-zip'
path = require 'path'

Zip64VariantExtractor = (variant) ->
	self = {}

	zip = new Zip variant, base64: true, checkCRC32: true
	files = zip.files

	# Iterator that allows the caller to extract files iteratively based on the
	# caller supplied filter.
	self.extract = ->
		# Find the variant image file
		for fname of files
			yield name: fname, buff: Buffer.from files[fname].asArrayBuffer()

	# Get the data files by their extension, e.g. extractor.file '.rgn'
	self.file = (regex) ->
		for fname of zip.files when regex.test(fname)
			# NOTE: This will make a full copy of the text in the
			# background so if there are performance issues then we could
			# consider passing this around in an object wrapper like a
			# buffer.
			return zip.files[fname].asText().split /[\r\n]+/ 

	return self

module.exports = Zip64VariantExtractor
