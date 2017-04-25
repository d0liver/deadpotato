Zip  = require 'node-zip'
path = require 'path'

Zip64VariantExtractor = (variant) ->
	self = {}

	zip = new Zip variant, base64: true, checkCRC32: true
	files = zip.files

	# Iterator that allows the caller to extract files iteratively based on the
	# caller supplied filter.
	self.extract = (filter) ->
		# Find the variant image file
		for fname of files when new_name = filter fname
			yield name: new_name, buff: Buffer.from files[fname].asArrayBuffer()

	# Get the data files by their extension, e.g. extractor.file '.rgn'
	self.file = (target_ext) ->
		for fname of zip.files
			{ext} = path.parse fname
			if ext is target_ext
				# NOTE: This will make a full copy of the text in the
				# background so if there are performance issues then we could
				# consider passing this around in an object wrapper like a
				# buffer.
				return zip.files[fname].asText().split /[\r\n]+/ 

	return self

module.exports = Zip64VariantExtractor
