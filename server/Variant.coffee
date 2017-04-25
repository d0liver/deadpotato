# File parsers
cnt = require "./cnt"
gam = require "./gam"
map = require "./map"
rgn = require "./rgn"

# Extractor is some strategy for pulling the variant files in a way that's
# convenient for us to use. The point of doing this is so that the variant
# parser logic conflated with and bloated by every possible means of variant
# extraction (even though it's entirely possible there is only ever going to be
# one, i.e. from a zip file).
Variant = (extractor) ->
	self = {}

	self.parse      = ->
		season_year = null
		name        = null
		countries   = null
		abbr_map    = null
		regions     = null

		countries = cnt extractor.file '.cnt'

		{abbr_map, regions} = map extractor.file '.map'

		{regions: gam_rgns, variant: name, season_year} =
			gam extractor.file('.gam'), abbr_map, countries
		Object.assign regions[rname], region for rname,region of gam_rgns

		rgn_regions = rgn extractor.file('.rgn'), Object.keys regions
		regions[rname].scanlines = region for rname,region of rgn_regions

		return {season_year, name, countries, abbr_map, regions}

	self.expects = (ext) ->
		return ext in expected_extensions

	return self

module.exports = Variant
