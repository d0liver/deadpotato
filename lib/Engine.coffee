{ResolverException} = require '../lib/Exceptions'

# GameData gd
Engine = (gd, Resolver) ->
	self = {}
	report = []
	# Orders are keyed by their acting unit for easier/faster lookup (e.g. the
	# unit moving, the unit supporting, the unit convoying)
	orders = {}

	rlog = (msg) -> report.push(msg)

	# From and to are region names
	self.addMove = (from, to) ->
		game_data.addOrder type: 'MOVE', {from, to}

	self.addSupport = (supporter, from, to) ->
		game_data.addOrder type: 'SUPPORT', {supporter, from, to}

	self.canSupport = (supporter, to) ->
		game_data.isAdjacent(supporter, to)

	# Order morder = The move order to support
	self.canMove = (morder) ->
		# Check and make sure that we don't have another unit moving to that
		# space already.
		move_exists = ! game_data.ordersWhere null, 'MOVE', 'EXISTS', {to}

		# If we can support there and we don't already have a unit there then
		# we can move there.
		return move_exists and self.canSupport(morder)

	# Order order = The convoy order
	self.addConvoy = (order) ->
		if self.canConvoy(order)
			gd.addOrder(order)
		else
			rlog "Invalid convoy order: #{order}"

		return

	self.adjacentConvoys = (order) ->
		return unless order.type is 'MOVE' or order.type is 'CONVOY'

		# Find adjacent convoy orders to the same destination.
		[convoy_ord] = gd.ordersWhere null, 'CONVOY', 'EXISTS', to: order.to
		convoy_ord? and self.isAdjacent(order.unit, convoy_ord.unit)

	self.isAdjacent = (rname1, rname2) ->
		{adjacencies} = regions[rname1]

		for adj in adjacencies when adj.region is rname2
			# TODO: Currently we're ignoring coastal specific adjacencies
			return \
				adj.type is 'xc' and unit.type is 'Fleet' or
				adj.type is 'mv' and unit.type is 'Army'

	self.resolve = ->
		resolver = Resolver self, gd, false
		return resolver.resolve()

	return self

module.exports = Engine
