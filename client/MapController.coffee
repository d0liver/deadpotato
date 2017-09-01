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

	countries = gdata.phase.countries; regions = vdata.map_data.regions
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
	for {name, units, color, supply_centers} in countries
		for unit in units
			region = regions[unit.region]
			region.fill = unit.region in supply_centers
			region.icon = unit.type
			region.color = color

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
			order = "#{country}: #{utypeAbbrev utype} #{active[0]} - #{selected}"
			setOrder order
			map.select selected
			showOrders()
		# Either support or convoy active[0] depending on if a modifier key has
		# been pressed.
		else if active.length > 1
			utype = board.region(selected).unit.type
			country = board.region(selected).unit.country.name
			dest_utype = utypeAbbrev board.region(active[0]).unit.type
			otype = (shift_down or ctrl_down) and 'Convoys' or 'Supports'
			order = "
				#{country}: #{utypeAbbrev utype} #{selected} #{otype}
				#{dest_utype} #{active[0]} - #{active[1]}
			"
			setOrder order
			map.select selected
			showOrders()

	utypeAbbrev = (type) -> type[0]

	setOrder = (order) ->
		order = Object.assign {}, text: order, parseOrder(order)
		old_order = orders.find (o) -> o.actor is order.actor
		orders = orders.filter (o) ->
			order.type is MOVE and o.from isnt old_order?.from or
			o.actor isnt order.actor

		orders.push order

	showOrders = ->
		map.clearArrows()

		console.log "ORDERS: ", orders

		for order in orders
			switch order.type
				when MOVE
					map.arrow order.from, order.to
				when SUPPORT
					map.bind order.from, order.to, order.actor

		# Keep a list of the convoy segments that have already been drawn to
		# keep from overdrawing.
		shown_segs = []
		cunits = for order in orders when order.type is CONVOY
			board.region(order.actor).unit

		for order in orders when order.type is MOVE
			path = pfinder.convoyPath order, cunits

			for branch in path
				# Draw the first segment from the source region to the first
				# convoying fleet
				map.convoy order.from, branch[0].region

				for i in [0...branch.length]
					unit = branch[i]; next_unit = branch[i+1]
					if next_unit?
						map.convoy unit.region, next_unit.region

				console.log branch[branch.length - 1].region, order.to
				# Draw the last convoy segment to the destination
				# map.arrow 
				map.arrow branch[branch.length - 1].region, order.to

			# Get a list of the path regions. We don't want to draw any of
			# those with the regular triangle stuff because they can be drawn
			# sensibly by the logic above.
			pregions = _.flatten(path).map (u) -> u.region

			for cunit in cunits when cunit.region not in pregions
				map.convoy order.from, cunit.region
				map.arrow cunit.region, order.to

			console.log "PATH: ", path

	# TODO: Good design decisions happening here?
	self.orders = -> utils.copy orders.map (o) -> o.text

	return self

module.exports = MapController
