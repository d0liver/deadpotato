rgn = (lfeed, variant_data) ->
	{regions} = variant_data
	# Skip the first line, it's just there for info
	lfeed.next()

	parsePos = (line) ->
		if /(\d+),(\d+)/.test line
			line.split(',').map (i) -> parseInt i

	parseRegion = (region) ->
		unit_pos = parsePos(lfeed.next().value)
		name_pos = parsePos(line = lfeed.next().value)
		# TODO: This is a bit sloppy but it's necessary since the name_pos
		# doesn't exist for coasts. Will need to come up with something better.
		if name_pos
			line = lfeed.next().value
		num_scanlines = parseInt(line)
		scanlines = for i in [1..num_scanlines]
			patt = /(\d+) (\d+) (\d+)/
			line = lfeed.next().value
			# We can't pass parseInt to the map directly because the second
			# argument to it is normally the radix (and we will end up passing
			# it as the index)
			[x, y, len] = line.match(patt)[1..].map (i) -> parseInt i
			x: x, y: y, len: len
		return {scanlines, unit_pos, name_pos}

	# Parse out the scanlines for each region
	for rname,region of regions
		Object.assign region, parseRegion(region)
		for cname,coast of region.coasts
			Object.assign coast, parseRegion(coast)

	return

module.exports = rgn
