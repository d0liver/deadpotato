# Wrapper around the game data to make it easier to access/manipulate and
# provides a nice API so that we can change the underlying representation of
# the variant and orders later if we want to.

GameData = (variant_data) ->
	self = {}
	orders = []

	# Make a copy of the variant data - we're not supposed to modify it
	variant_data = JSON.parse JSON.stringify variant_data

	init = ->

		for country in variant_data.countries

			for unit in country.units
				region = variant_data.regions[unit.region]
				unit.country =  country
				unit.region = region
				region.unit = unit

			# TODO: This loop and the one above are the same. We could extract
			# this somehow but I don't want to add a lot of complexity to do
			# it.
			for center,i in country.supply_centers
				region = variant_data.regions[center]
				center = country.supply_centers[i] = {}
				center.country = country
				center.region = region
				region.is_supply_center = true

		return variant_data

	# TODO: memoize this
	self.units = ->
		for country in variant_data.countries
			for unit in country.units
				unit

	self.addOrder = (order) -> orders.push deepCopy order

	actor = (order) ->
		switch order.type
			when 'MOVE' then order.from
			when 'CONVOY' then order.convoyer
			when 'SUPPORT' then order.supporter

	# Fast way to get orders with certain constraints. When we call this function
	# it's almost always to find __other__ orders that will affect the order
	# currently being adjudicated. As such, we almost never want to consider the
	# _current_ order in our results so we take it as the first argument which
	# makes the function signature slightly more confusing but is much more
	# convenient.
	self.ordersWhere = (current, type, requires, matches) ->
		results = []
		`outer: //`
		for order in orders when order.type is type and order isnt current
			for key, value of matches
				# Check if the order values match the key value pairs given in the
				# matches or if a function was provided instead of a value then
				# evaluate that function as a filter on the given key (slightly
				# confusing but the actual usage is intuitive and handy).
				if (typeof value isnt "function" and order[key] isnt value) or
				typeof value is "function" and not value(order[key])
					`continue outer`

			# In some cases we only care if an order exists. Therefore, if _exists_
			# is true then we return the order simply because we found it. Other
			# times, we care specifically if the order succeeded or failed. In
			# these cases one can set _succeeds_ and only orders which match that
			# criterion will be returned.
			if requires is 'EXISTS' or
			(self.adjudicate(order) and requires is 'SUCCEEDS') or
			(!self.adjudicate(order) and requires is 'FAILS')
				results.push order

		# This makes it so that we can use the results as a boolean or use the
		# actual results which is convenient.
		return results if results?.length

	deepCopy = (object) -> JSON.parse JSON.stringify object

	init()
	return self

module.exports = GameData
