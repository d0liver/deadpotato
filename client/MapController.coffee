$            = require 'jquery'
{parseOrder} = require '/home/david/gavel'
_            = require 'underscore'

utils                                                = require '../lib/utils'
{enums: {english, outcomes, orders: eorders, paths}} = require '/home/david/gavel/'
{MOVE, SUPPORT, CONVOY, HOLD}                        = eorders

MapController = (board, pfinder, map, gdata, vdata) ->
	self = {}
	shift_down = false; ctrl_down = false

	$(document).on 'keydown', (e) ->
		if e.which is 16
			shift_down = true
		else if e.which is 17
			ctrl_down = true
		else if e.which is 27
			map.clearActive()

	countries = gdata.countries; regions = vdata.map_data.regions
	orders = []

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
			regions[unit.region].icon = unit.type

	# Once modifications have been done (above) we add all regions.
	map.addRegion n,region for n,region of regions

	map.display()

	map.on 'select', ->
		selected = this.id
		# Get a list of the active ids.
		active = map.active()

		# Initial selection
		if active.length is 0
			map.select selected
		# Select a destination region for the move
		else if active.length is 1 and selected isnt active[0]
			utype = board.region(active[0]).unit.type
			country = board.region(active[0]).unit.country.name
			if board.canMove {utype, from: active[0], to: selected}
				order = "#{country}: #{utypeAbbrev utype} #{active[0]} - #{selected}"
				setOrder parseOrder order
				map.select selected
				showOrders()
		# Either support or convoy active[0] depending on if a modifier key has
		# been pressed.
		else if active.length is 2 and (
			(shift_down or ctrl_down)
			# and board.canConvoy({actor: selected, to: active[1], utype})
		) or board.canSupport({actor: selected, to: active[1], utype})
			utype = board.region(selected).unit.type
			country = board.region(selected).unit.country.name
			dest_utype = utypeAbbrev board.region(active[0]).unit.type
			otype = (shift_down or ctrl_down) and 'Convoys' or 'Supports'
			order = "
				#{country}: #{utypeAbbrev utype} #{selected} #{otype}
				#{dest_utype} #{active[0]} - #{active[1]}
			"
			console.log "ORDER: ", order
			setOrder parseOrder order
			map.select selected
			showOrders()

	utypeAbbrev = (type) -> type[0]

	setOrder = (order) ->
		old_order = orders.find (o) -> o.actor is order.actor
		orders = orders.filter (o) ->
			order.type is MOVE and o.from isnt old_order?.from or
			o.actor isnt order.actor

		orders.push order

	showOrders = ->
		map.clearArrows()

		for order in orders
			switch order.type
				when MOVE
					map.arrow order.from, order.to
				when SUPPORT
					map.bind order.from, order.to, order.actor
				when CONVOY
					map.convoy order.from, order.to, order.actor

	return self

module.exports = MapController
