gam = (lines, variant_data) ->
	mapAbbr = (abbr) -> variant_data.abbr_map[abbr.toLowerCase()]
	unit_type_map = A: 'Army', F: 'Fleet'

	# Skip the first line - it's just the version number
	lines.splice 0, 1
	[game_name, name, season_year] = lines.splice 0, 3
	[num_adjust, num_countries] = lines.splice(0, 2).map parseInt

	for country in variant_data.countries
		adjustment = parseInt lines.splice 0, 1
		[centers, units] = lines.splice(0, 2).map (line) -> line.split /\s+/ 

		country.supply_centers = (mapAbbr center for center in centers)

		country.units = while ([type, region] = units.splice(0, 2)).length
			type: unit_type_map[type], region: mapAbbr region

	Object.assign variant_data, {game_name, name, season_year}
	return

	# There could be relevant info after this but stuff after this line
	# shouldn't be used for _new_ variants so maybe we will add the remaining
	# stuff later. It's less clear from the docs how to parse it.

module.exports = gam
