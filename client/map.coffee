map = (lines) ->
	regions = {}
	l = (str) -> str.toLowerCase()

	sectionIter = (m) ->
		m line while (line = lines.splice(0, 1)[0])?.length and line isnt "-1"

	sectionIter (line) ->
		[..., name, letter, abbrs] = line.match /([^,]+),\s+(\w+) (.+)$/
		regions[name] =
			type_letter: letter
			abbrs: abbrs.split(/\s+/).map l

	# This is a reverse map that goes from a regions abbreviations it its name
	# for fast lookup.
	abbr_map = {}
	for name,region of regions
		for abbr in region.abbrs 
			abbr_map[l abbr] = name

	adjacencies = sectionIter (line) ->
		[..., abbr, adj_type, adj_abbrs] = line.match ///
			(\w+)\-
			(mv|xc|nc|sc|ec|wc|mx)\:\s+
			(.+)$
		///

		region = regions[abbr_map[l abbr]]
		region.adjacencies =
			for adj in adj_abbrs.split(/\s+/).filter((i) -> not /^\s+$/.test i)
				type: adj_type
				region: abbr_map[l adj]

	regions: regions
	abbr_map: abbr_map

module.exports = map
