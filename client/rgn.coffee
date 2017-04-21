rgn = (lines, regions) ->
	res = {}
	# Skip the first line, it's just there for info
	lines[0..0] = []
	# First, we filter out all of the comments in the file
	lines = lines.filter (line) -> not /^\s*\#/.test line

	# Parse out the scanlines for each region
	for region in regions
		[unit_pos, name_pos] = lines.splice(0, 2).map (l) -> l.split ","
		num_scanlines = parseInt lines.splice(0, 1)[0]
		res[region] = for i in [0...num_scanlines]
			patt = /(\d+) (\d+) (\d+)/
			[x, y, len] = lines.splice(0, 1)[0].match(patt).map (i) -> parseInt i
			x: x, y: y, len: len

	res

module.exports = rgn
