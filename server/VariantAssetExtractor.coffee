path         = require 'path'
{capitalize} = require '../lib/utils'
VariantUtils = require '../lib/VariantUtils'
MapIcon      = require '../lib/MapIcon'

# Determines which variant files we should extract and save (to S3)
VariantAssetExtractor = ({slug, countries}, extractor) ->
	self = {}
	colors = vutils.colors()

	isIcon = (fname) ->
		{ext, name, base} = path.parse fname
		ico_regex = /(.+)(Army|Fleet)$/

		if ext is '.ico' and ico_regex.test name
			color = name.match(ico_regex)[1]
			if color.toLowerCase() in colors
				return "#{slug}/#{base}"
		return

	isMapImage = (fname) ->
		{ext, name, base} = path.parse fname
		# Use the .bmp file that doesn't end with 'bw' (for black and
		# white) or -borders which is a special file used for scanline
		# generation (I think) in RP. There should only be one such .bmp.
		if not /(bw|\-borders)$/i.test(name) and ext is '.bmp'
			return "#{slug}/map.bmp"

		return

	fallbackIcon = (color, type) -> 

	self.assets = ->

		# Try to extract icons first. Set fallbacks to the standard variant for
		# any icons that aren't found in this variant.
		for country in countries
			for type in ['Army', 'Fleet']
				icon = MapIcon(slug, country.color, type)
				country.icons[icon.name()] =
					unless file = extractor.file(///#{icon.name()}\.ico$///)
						MapIcon('standard', color, type).relativeUri()
					else
						icon.relativeUri()
					

		# Extract the map file
		extractor.file(///)
		for {name, buff} from extractor.extract()
			if isIcon(name)
				seen_icons.push name

	return self

module.exports = ExtractorFilter
