path         = require 'path'
{capitalize} = require '../lib/utils'
VariantUtils = require '../lib/VariantUtils'
MapIcon      = require '../lib/MapIcon'
through      = require 'through2'

# Determines which variant files we should extract and save (to S3)
VariantAssetExtractor = ({slug, countries}, extractor) ->
	self = {}
	colors = countries.map (country) -> country.color

	isIcon = (fname) ->
		{ext, name, base} = path.parse fname
		ico_regex = /(.+)(Army|Fleet)$/

		if ext is '.ico' and ico_regex.test name
			color = name.match(ico_regex)[1]
			if color.toLowerCase() in colors
				return "/#{slug}/#{base}"
		return

	isMapImage = (fname) ->
		{ext, name, base} = path.parse fname
		# Use the .bmp file that doesn't end with 'bw' (for black and
		# white) or -borders which is a special file used for scanline
		# generation (I think) in RP. There should only be one such .bmp.
		if not /(bw|\-borders)$/i.test(name) and ext is '.bmp'
			return "/#{slug}/map.bmp"

		return

	fallbackIcon = (color, type) -> 

	self.extract = ->
		return through.obj (file, enc, cb) ->
			if fname = (isIcon(file.relative) or isMapImage(file.relative))
				file.path = fname
				cb null, file
			else
				cb()

	return self

module.exports = VariantAssetExtractor
