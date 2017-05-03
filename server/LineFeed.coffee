# Used to feed lines to the various parsers. Strips out comments, empty lines,
# etc.
LineFeed = (raw) ->
	# TODO: Deal with inlined comments
	empty = /^\s*$/
	comment = /^\s*#/
	raw_lines = raw.split /[\r\n]+/

	for line in raw_lines when not (empty.test(line) or comment.test(line)) 
		yield line

module.exports = LineFeed
