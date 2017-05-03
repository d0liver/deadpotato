Zip     = require 'node-zip'
path    = require 'path'
Vinyl   = require 'vinyl'
through = require 'through2'

Zip64VariantExtractor = (b64) ->
	self = {}

	zip = new Zip b64, base64: true, checkCRC32: true
	files = zip.files

	# Supplies a stream of file vinyls (like gulp.src) to be consumed.
	self.extract = ->
		stream = through.obj()
		for fname,file of files
			stream.write new Vinyl
				cwd: '/'
				base: '/'
				path: '/'+fname
				contents: Buffer.from file.asArrayBuffer()

		stream.end()

		return stream

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
