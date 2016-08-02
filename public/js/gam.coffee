window.gam = (lines, abbr_map, countries) ->
	regions = {}
	mapAbbr = (abbr) -> abbr_map[abbr.toLowerCase()]

	# Skip the first line - it's just the version number
	lines.splice 0, 1
	[game_name, variant, season_year] = lines.splice 0, 3
	[num_adjust, num_countries] = lines.splice(0, 2).map parseInt

	for country in countries
		adjustment = parseInt lines.splice 0, 1
		[centers, units] = lines.splice(0, 2).map (line) -> line.split /\s+/ 

		for center in centers
			regions[mapAbbr center] = country: country.name

		while ([type, region] = units.splice(0, 2)).length
			regions[mapAbbr region].unit = type 

	regions: regions
	game_name: game_name
	variant: variant
	season_year: season_year

	# There could be relevant info after this but stuff after this line
	# shouldn't be used for _new_ variants so maybe we will add the remaining
	# stuff later. It's less clear from the docs how to parse it.
