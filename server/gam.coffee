{coastName} = require '../lib/parseUtils'

gam = (lfeed, variant_data) ->
	mapAbbr = (abbr) -> variant_data.abbr_map[abbr.toLowerCase()]
	unit_type_map = A: 'Army', F: 'Fleet'

	# Skip the first line - it's just the version number
	lfeed.next()
	[game_name, name, season_year] = (lfeed.next().value for i in [1..3])
	[num_adjust, num_countries] = (parseInt(lfeed.next().value) for i in [1..2])

	for country in variant_data.countries
		adjustment = parseInt(lfeed.next().value)
		[centers, units] = (lfeed.next().value.split(/\s+/) for i in [1..2])

		country.supply_centers = (mapAbbr center for center in centers)

		country.units = []
		while ([type, region] = units.splice(0, 2)).length
			result = type: unit_type_map[type]
			# Starting units that are on a coast are represented like this:
			# StP(sc). So, we have to parse out the coast name if there is one.
			if '(' in region
				[region, coast_abbr] = region.split '('
				# Remove the trailing paren from the coast abbreviation
				coast_abbr = coast_abbr[0...-1]
				result.coast = coastName(coast_abbr)

			result.region = mapAbbr(region)
			country.units.push(result)

	Object.assign variant_data, {game_name, name, season_year}
	return

	# There could be relevant info after this but stuff after this line
	# shouldn't be used for _new_ variants so maybe we will add the remaining
	# stuff later. It's less clear from the docs how to parse it.

module.exports = gam
