{VariantParseException} = require '../lib/Exceptions'
{coastName} = require '../lib/parseUtils'

map = (lfeed, variant_data) ->
	regions = {}
	abbr_map = {}

	regionType = (letters) ->
		m = 
			l: 'Land'
			w: 'Water'
			lw: 'Coast'

		if letters in Object.keys m
			return m[letters]
		# This is how home supply centers are designated. We don't actually
		# need to know which country this center is for - we can get that
		# from the .gam file. These centers are assumed to be land.
		else if /^[A-Z]$/.test letters
			return 'Land'

	# This is used to iterate over each of the following sections in the file.
	# Loop through lines until -1 is encountered calling our function argument,
	# _m_, with each line.
	nextSection = (m) ->
		while line = lfeed.next().value
			break if line is '-1'
			# Advance to the next line so that we can read the next entry
			# on the next call.
			m(line)

	# Iterate over the first section which gives the name of each region and
	# its corresponding abbreviations and region type (Land, Water, or Coast).
	# We do not keep the abbreviations because we don't actually care about
	# them. The full name is kept verbatim and the type is translated to a
	# nonabbreviated version (e.g. w becomes Water).
	nextSection (line) ->
		[..., full_name, type_letters, abbrs] = line.match ///
			([^,]+), # Region full name
			\s+(\w+) # Region type letters (mapped to Land, Water, or Coast)
			(.+)$    # Abbreviations for the region
		///
		regions[full_name] = type: regionType type_letters

		# Build a reverse map that goes from a region's abbreviations to its
		# name for fast lookup.
		for abbr in abbrs.split /\s+/
			abbr = abbr.toLowerCase()
			abbr_map[abbr] = full_name

		return

	# Used to build an adjacency based off of an abbreviation with an optional
	# coast specification (like stp/nc). _abbr_ determines where units can move
	# __to__ whereas the _adjacency_type_ determines where units can move
	# __from__.
	#
	# Adjacency type determines when units can move __from__ the region we're
	# specifying adjacencies for to the other region. xc indicates that only a
	# fleet can move. mv indicates that only an army can move. nc, sc, ec, and
	# wc all indicate that only a fleet can move and only __from__ the
	# corresponding coast. E.g. an adjacency_type of 'nc' indicates that only a
	# fleet can move to the destination region and only __from__ the north
	# coast.
	parseAdjacency = (abbr, adjacency_type) ->
		adjacency = {}

		[abbr, coast] = abbr.split '/'

		# Destination region and coast
		adjacency.region = abbr_map[abbr]
		adjacency.coast = coastName coast if coast?

		# The type of unit that can move there
		adjacency.for = adjacency_type in ['xc', 'nc', 'sc', 'ec', 'wc'] and 'Fleet' or 'Army'

		return adjacency


	# The second section contains the actual adjacencies for each region. The
	# format is like this: bar-xc: nwg stp/nc nor
	# which would indicate that fleets in the Barents sea (xc indicates a fleet
	# adjacency and bar is the abbreviation for the Barents sea) can move to
	# the Norweigan Sea (nwg), St Petersburg on the north coast only (because
	# of the /nc in the adjacency), or to Norway.
	nextSection (line) ->
		matches = line.match ///
			(\w+)\-                     # We're getting the adjacencies of this region
			(mv|xc|nc|sc|ec|wc|mx)\:\s+ # Which units can move from here to the adjacencies below
			(.+)              # Abbreviations for adjacent regions
			$
		///

		region = regions[abbr_map[matches[1].toLowerCase()]]

		adjacencies =
			for abbr in matches[3].trim().split /\s+/
				parseAdjacency abbr, matches[2]

		region.coasts ?= {}

		# If these adjacencies apply only to units coming from one of our
		# coasts then we deal with that here.
		if matches[2] in ['nc', 'sc', 'ec', 'wc']
			coast = (region.coasts[coastName(matches[2])] ?= adjacencies: [])
			coast.adjacencies = adjacencies
		else
			region.adjacencies.push adjacencies...

	Object.assign variant_data, {regions, abbr_map}
	return

module.exports = map
