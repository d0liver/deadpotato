rgn = (lines, variant_data) ->
	{regions} = variant_data
	# Skip the first line, it's just there for info
	lines[0..0] = []
	# First, we filter out all of the comments in the file
	lines = lines.filter (line) -> not /^\s*\#/.test line

	# Parse out the scanlines for each region
	for rname,region of regions
		[unit_pos, name_pos] = lines.splice(0, 2).map (l) -> l.split(",").map (i) -> parseInt i
		num_scanlines = parseInt lines.splice(0, 1)[0]
		scanlines = for i in [0...num_scanlines]
			patt = /(\d+) (\d+) (\d+)/
			# We can't pass parseInt to the map directly because the second
			# argument to it is normally the radix (and we will end up passing
			# it as the index)
			[x, y, len] = lines.splice(0, 1)[0].match(patt)[1..].map (i) -> parseInt i
			x: x, y: y, len: len
		Object.assign region, {scanlines, unit_pos, name_pos}

	return

module.exports = rgn
