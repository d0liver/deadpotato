Zip  = require 'node-zip'
path = require 'path'

Zip64VariantExtractor = (variant) ->
	self = {}

	zip = new Zip variant, base64: true, checkCRC32: true
	files = zip.files

	self.image = ->
		# Find the variant image file
		for fname of files
			{ext, name, base} = path.parse fname

			# Use the .bmp file that doesn't end with 'bw' (for black and
			# white) or -borders which is a special file used for scanline
			# generation (I think) in RP. There should only be one such .bmp.
			if not /(bw|\-borders)$/.test(name) and ext is '.bmp'
				return Buffer.from files[fname].asArrayBuffer()
		return

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
