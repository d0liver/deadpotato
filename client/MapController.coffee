MapController = (engine, map, {countries, regions}) ->
	self = {}

	# Shallow copy all of the regions so that our modifications for the Map
	# don't become global.
	for rname,region of regions
		regions[rname] = Object.assign {}, region

	# Augment each country's region with the country's color and add it to the
	# map. We do things this way instead of passing in the variant_data and
	# having the map iterate that because we don't always know exactly how
	# iteration will need to proceed in order for the map to determine exactly
	# what to display (for instance we might want to highlight regions
	# independently of their affiliation with any country later) so it's left
	# up to this module to determine _what_ to display and hand that off to the
	# map in a generic way. We are guaranteed by Map's API that adding a region
	# that already exists will overwrite the previous one.
	for country in countries
		for center in country.supply_centers
			region = regions[center]
			regions[center].color = country.color

		for unit in country.units
			console.log "Unit region: ", unit.region
			regions[unit.region].icon = unit.type

	# Once modifications have been done (above) we add all regions.
	map.addRegion n,region for n,region of regions

	map.display()

	map.on 'select', ->
		selected = this.id
		# Get a list of the active ids. Under normal rules there will never be
		# more than two (in the case of convoy or support).
		active = map.active()

		#  Select a unit to support. Okay to select a region that we don't own.
		if active.length is 1 and
		engine.regionUnit(selected) and
		selected isnt active[0]
			map.select selected
		# Select where to support the unit to
		else if active.length is 2 and engine.canSupport active[0], selected
			engine.addSupport active[0], active[1], selected
			map.clearActive()
			showOrders()
		# Move
		else if active.length is 1 and engine.canMove active[0], selected
			engine.addMove active[0], selected
			map.clearActive()
			showOrders()
		# Initial selection
		else if engine.playerOwns(selected) and active.length is 0
			map.select selected
		else
			map.clearActive()

	showOrders = ->
		map.clearArrows()

		for order in engine.orders()
			console.log "ORDER: ", order
			switch order.type
				when 'MOVE' then map.arrow order.from, order.to
				when 'SUPPORT'
					map.bind order.from, order.to, order.supporter

	return self

module.exports = MapController
