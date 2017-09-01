# File parsers
cnt                     = require "./cnt"
gam                     = require "./gam"
map                     = require "./map"
rgn                     = require "./rgn"
slug                    = require 'slug'
LineFeed                = require './LineFeed'
{VariantParseException} = require '../lib/Exceptions'
through                 = require 'through2'

# Extractor is some strategy for pulling the variant files in a way that's
# convenient for us to use. The point of doing this is so that the variant
# parser logic conflated with and bloated by every possible means of variant
# extraction (even though it's entirely possible there is only ever going to be
# one, i.e. from a zip file).
parseVariant = (stream) ->
	variant_data = {}
	files = {}

	new Promise (resolve, reject) ->
		# Gather up the files that we need from the incoming vinyl stream and then
		# parse them in the correct order.
		stream.on 'data', (file) ->
			ext = file.relative.split('.')[-1..-1][0]
			if ext in ['cnt', 'map', 'rgn', 'gam']
				files[ext] = file.contents
		.on 'end', ->
			# Make sure the type order below is correct. In particular, the .gam
			# file uses the abbreviations map from the .map file and countries from
			# the .cnt file.
			for name,parse of {cnt, map, rgn, gam}
				if not files[name]?
					return def.reject new VariantParseException(".#{name} file was not found.")
				else
					parse LineFeed(files[name].toString('utf8')), variant_data

			# The regions object (scanlines, adjacencies, etc.) isnt't really
			# useful except for when we're actually displaying a map so it doesn't
			# make sense to spend a lot of time trying to get it into a format that
			# Mongo and GraphQL like. We might even consider sending it over to S3
			# as static data and letting all of the parsing be done on the
			# frontend. For now we just stringify and store as "map data". Note
			# that we store the regions in map_data rather than as map_data because
			# we could end up needing other stuff as map_data in the future.
			variant_data.map_data = JSON.stringify {regions: variant_data.regions}

			# Delete abbr_map also since parsed data doesn't use abbreviations
			# ever.
			delete variant_data.abbr_map; delete variant_data.regions

			variant_data.slug = slug variant_data.name, lower: true

			resolve variant_data

module.exports = parseVariant
