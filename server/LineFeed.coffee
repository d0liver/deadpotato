# Used to feed lines to the various parsers. Strips out comments, empty lines,
# etc.
LineFeed = (raw_lines) ->
	# TODO: Deal with inlined comments
	empty = /^\s*$/
	comment = /^\s*#/

	for line in raw_lines when not (empty.test(line) or comment.test(line)) 
		yield line

module.exports = LineFeed
