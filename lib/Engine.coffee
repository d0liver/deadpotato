{ResolverException} = require '../lib/Exceptions'

Engine = ({countries, regions}, player_country_name, Resolver) ->
	self = {}
	# Orders are keyed by their acting unit for easier/faster lookup (e.g. the
	# unit moving, the unit supporting, the unit convoying)
	orders = {}
	player_country = do ->
		for country in countries when country.name is player_country_name
			return country

	self.addOrder = (order) ->
		actor = (type) ->
			switch type
				when 'MOVE' then 'from'

		if order.type is 'MOVE'
			orders[actor(order)] = order

	# From and to are region names
	self.addMove = (from, to) ->
		orders[from] = Object.assign {}, type: 'MOVE', {from, to}

	self.addSupport = (supporter, from, to) ->
		orders[supporter] = Object.assign {}, type: 'SUPPORT', {supporter, from, to}

	self.canSupport = (supporter, to) ->
		# Get the supporting unit
		unit = self.regionUnit supporter
		{adjacencies} = regions[supporter]

		for adj in adjacencies when adj.region is to
			# Currently we're ignoring coastal specific adjacencies
			return \
				adj.type is 'xc' and unit.type is 'Fleet' or
				adj.type is 'mv' and unit.type is 'Army'

	# _from_ and _to_ are region names
	self.canMove = (from, to) ->

		# Check and make sure that we don't have another unit moving to that
		# space already.
		for actor,order of orders when order.type is 'MOVE' and order.to is to
			return false

		# If we can support there and we don't already have a unit there then
		# we can move there.
		unless self.canSupport from, to
			return false

		return true

	self.hasOrder = (unit) -> !! orders[unit.region]

	self.playerOwns = (region) ->
		for unit in player_country.units when unit.region is region
			return true

		return false

	self.orders = -> Object.values orders

	# We don't do any checking on the convoy path here. That will be handled in
	# the resolver.
	self.canConvoy (convoyer) ->
		return regionUnit(convoyer).type isnt 'Fleet'

	self.addConvoy = (order) ->
		unless self.canConvoy(order.convoyer)
			return null
		else
			orders[order.convoyer] = order

	fleets = yield from units.bind null, 'Fleet'
	armies = yield from units.bind null, 'Army'
	units = (type, iter) ->
		for {units} in countries
			for unit in units when unit.type is type
				yield [unit, regions[unit.region]]

	# Check and make sure all of the orders that have been added so far are
	# valid according to the map constraints.
	self.checkMapConstraints = ->
		for actor,order of orders
			if order.type is 'MOVE' and not self.canMove(order.from, order.to)
				msg = "Illegal order from #{order.from} to #{order.to}"
				throw new ResolverException(msg)

	self.adjacentConvoy = (order) ->
		for fleet in fleets()
			if order.type is 'MOVE' and regionUnit(fleet)?.convoyer is order.

	self.isAdjacent = (rname1, rname2) ->
		{adjacencies} = regions[rname1]

		for adj in adjacencies when adj.region is rname2
			# TODO: Currently we're ignoring coastal specific adjacencies
			return \
				adj.type is 'xc' and unit.type is 'Fleet' or
				adj.type is 'mv' and unit.type is 'Army'


	self.regionUnit = (rname) ->
		region = regions[rname]
		for {units} in countries
			for unit in units when unit.region is rname
				return unit

	self.resolve = ->
		console.log "Attempting to resolve orders..."
		# First, we have to build up a units object in the format expected by
		# the resolver.
		units = {}
		for country in countries
			for unit in country.units
				units[unit.region] = unit.type
		console.log "Resolver units: ", units

		try
			self.checkMapConstraints()
		resolver = Resolver orders, units
		# resolver.resolve()

	return self

module.exports = Engine
