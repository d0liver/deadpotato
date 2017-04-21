# .cnt file parser
cnt = (lines) ->
	# Skip the first line - it's just the version number
	lines = lines[1..]
	num_countries = parseInt lines[0]

	for line in lines[1..]
		[name, adjective, capital_initial, pattern, color] = line.split " "
		num_countries: num_countries
		name: name
		adjective: adjective
		capital_initial: capital_initial
		pattern: pattern
		color: color

module.exports = cnt
