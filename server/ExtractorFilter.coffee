path   = require 'path'
VariantUtils = require '../lib/VariantUtils'

# Determines which variant files we should extract and save (to S3)
ExtractorFilter = (variant_data) ->
	self = {}
	vutils = VariantUtils variant_data
	colors = vutils.colors()
	console.log "SLUG: ", variant_data.slug

	isIcon = (fname) ->
		{ext, name, base} = path.parse fname
		ico_regex = /(.+)(Army|Fleet)$/

		if ext is '.ico' and ico_regex.test name
			color = name.match(ico_regex)[1]
			if color.toLowerCase() in colors
				return "#{variant_data.slug}/#{base}"
		return

	isMapImage = (fname) ->
		{ext, name, base} = path.parse fname
		# Use the .bmp file that doesn't end with 'bw' (for black and
		# white) or -borders which is a special file used for scanline
		# generation (I think) in RP. There should only be one such .bmp.
		if not /(bw|\-borders)$/.test(name) and ext is '.bmp'
			return "#{variant_data.slug}/map.bmp"

		return

	self.filter = (fname) ->
		return isMapImage(fname) or isIcon(fname)

	return self

module.exports = ExtractorFilter
