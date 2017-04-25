cnt = (lines, variant_data) ->
	# Skip the first line - it's just the version number
	lines = lines[1..]

	variant_data.countries = for line in lines[1..]
		[name, adjective, capital_initial, pattern, color] = line.split " "
		{name, adjective, pattern, color: color.toLowerCase()}

	return

module.exports = cnt
