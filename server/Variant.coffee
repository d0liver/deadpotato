# File parsers
cnt      = require "./cnt"
gam      = require "./gam"
map      = require "./map"
rgn      = require "./rgn"
slug     = require 'slug'
LineFeed = require './LineFeed'

# Extractor is some strategy for pulling the variant files in a way that's
# convenient for us to use. The point of doing this is so that the variant
# parser logic conflated with and bloated by every possible means of variant
# extraction (even though it's entirely possible there is only ever going to be
# one, i.e. from a zip file).
Variant = (extractor) ->
	self = {}

	self.parse = ->
		variant_data = {}

		# Make sure the type order below is correct. In particular, the .gam
		# file uses the abbreviations map from the .map file and countries from
		# the .cnt file.
		for name,parse of {cnt, map, rgn, gam}
			file = extractor.file ///\.#{name}$///
			parse LineFeed(file), variant_data

		# The regions object (scanlines, adjacencies, etc.) isnt't really
		# useful except for when we're actually displaying a map so it doesn't
		# make sense to spend a lot of time trying to get it into a format that
		# Mongo and GraphQL like. We might even consider sending it over to S3
		# as static data and letting all of the parsing be done on the
		# frontend. For now we just stringify and store as "map data". Note
		# that we store the regions in map_data rather than as map_data because
		# we could end up needing other stuff as map_data in the future.
		variant_data.map_data = JSON.stringify {regions: variant_data.regions}

		# TODO: Storing the slug is probably unnecessary and should be removed.
		variant_data.slug = slug variant_data.name, lower: true

		# Delete abbr_map also since parsed data doesn't use abbreviations
		# ever.
		delete variant_data.abbr_map; delete variant_data.regions


		# The full list of keys on variant info is:
		# season_year
		# name (of the variant)
		# countries
		# map_data (abbreviations map and )
		# slug

		return variant_data

	self.expects = (ext) ->
		return ext in expected_extensions

	return self

module.exports = Variant
