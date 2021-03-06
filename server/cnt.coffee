cnt = (lfeed, variant_data) ->
	# Skip the first line - it's just the version number
	lfeed.next()
	# The second line is the number of countries we're expecting to read.
	lfeed.next()

	variant_data.countries = for line from lfeed
		[name, adjective, capital_initial, pattern, color] = line.split " "
		{name, adjective, pattern, color: color.toLowerCase()}

	return

module.exports = cnt
