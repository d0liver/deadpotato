map = (lfeed, variant_data) ->
	regions = {}
	abbr_map = {}
	l = (str) -> str.toLowerCase()

	region_type_map = (letters) ->
		m = 
			l: 'Land'
			w: 'Water'
			lw: 'Coast'

		if letters in Object.keys m
			return m[l]
		else if /^[A-Z]$/.test letters
			# This is how home supply centers are designated. We don't actually
			# need to know which country this center is for - we can get that
			# from the .gam file. These centers are assumed to be land.
			return 'Land'

	sectionIter = (m) ->
		for line from lfeed
			break if line is '-1'
			m(line)

	sectionIter (line) ->
		[..., name, letters, abbrs] = line.match /([^,]+),\s+(\w+) (.+)$/
		regions[name] = type: region_type_map letters
		# Build a reverse map that goes from a region's abbreviations to its
		# name for fast lookup.
		abbr_map[abbr] = name for abbr in abbrs.split(/\s+/).map l
		return

	sectionIter (line) ->
		[..., abbr, adj_type, adj_abbrs] = line.match ///
			(\w+)\-
			(mv|xc|nc|sc|ec|wc|mx)\:\s+
			(.+)$
		///

		region = regions[abbr_map[l abbr]]

		adjacencies =
			for adj in adj_abbrs.split(/\s+/).filter((i) -> not /^\s+$/.test i)
				type: adj_type
				region: abbr_map[l adj]

		region.adjacencies ?= []
		region.adjacencies.push adjacencies...

		return

	Object.assign variant_data, {regions, abbr_map}
	return

module.exports = map
