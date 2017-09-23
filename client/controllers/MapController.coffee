$            = require 'jquery'
{parseOrder} = require 'gavel.js'
_            = require 'underscore'

utils                                                = require '../../lib/utils'
{enums: {english, outcomes, orders: eorders, paths}} = require 'gavel.js'
{MOVE, SUPPORT, CONVOY, HOLD}                        = eorders

# Some useful keycodes
SHIFT = 16; CTRL = 17; ESC = 27

class MapController

	constructor: (@_gavel, @_board, @_pfinder, @_map, @_gdata, @_vdata) ->
		@_shift_down = false; @_ctrl_down = false; orders = []
		@_countries = @_gdata.phase.countries; @_regions = @_vdata.map_data.regions

		@_initMap()

		switch @_gavel.phase.season
			when 'Fall', 'Spring' then @_initMoveControls()
			when 'Winter' then @_initBuildControls()

	clearOrders: -> @_orders = []

	_initMap: ->

		# Shallow copy all of the regions so that our modifications for the Map
		# don't become global.
		for rname,region of @_regions
			@_regions[rname] = Object.assign {}, region

		# Augment each country's region with the country's color and add it to the
		# map.
		# XXX: We do things this way instead of passing in the variant_data and
		# having the map iterate that because we don't always know exactly how
		# iteration will need to proceed in order for the map to determine
		# exactly what to display (for instance we might want to highlight
		# regions independently of their affiliation with any country later) so
		# it's left up to this module to determine _what_ to display and hand
		# that off to the map in a generic way. We are guaranteed by Map's API
		# that adding a region that already exists will overwrite the previous
		# one.
		for {name, units, color, supply_centers} in @_countries
			for unit in units
				region = @_regions[unit.region]
				region.fill = unit.region in supply_centers
				region.icon = unit.type
				region.color = color

		# Once modifications have been done (above) we add all regions.
		@_map.addRegion n,region for n,region of @_regions

		@_map.display()

	# Input orders for the regular phases (Fall and Spring)
	_initMoveControls: ->

		$(document).on 'keydown', (e) =>
			switch e.which
				when SHIFT then @_shift_down = true
				when CTRL then @_ctrl_down = true
				# Clear the active selection when escape is pressed
				when ESC then @_map.clearActive()

		self = this
		@_map.on 'select', =>
			selected = @id
			# Get a list of the active ids.
			active = self._map.active()

			# It's not valid for the first selection to be a region without a
			# unit. The second selection is, in fact, the only selection that
			# it's valid to do on a region without a unit (since it's the
			# destination of a move)
			if not self._board.region(selected).unit? and active.length isnt 1
				self._map.clearActive()
				return

			# Initial selection
			if active.length is 0
				@_map.select selected
			# Select a destination region for the move
			else if active.length is 1 and selected isnt active[0]
				utype = @_board.region(active[0]).unit.type
				country = @_board.region(active[0]).unit.country.name
				order = "#{country}: #{@_utypeAbbrev utype} #{active[0]} - #{selected}"
				@_setOrder order
				@_map.select selected
				@_showOrders()
			# Either support or convoy active[0] depending on if a modifier key has
			# been pressed.
			else if active.length > 1
				utype = @_board.region(selected).unit.type
				country = @_board.region(selected).unit.country.name
				dest_utype = @_utypeAbbrev @_board.region(active[0]).unit.type
				otype = (@_shift_down or @_ctrl_down) and 'Convoys' or 'Supports'
				order = "
					#{country}: #{@_utypeAbbrev utype} #{selected} #{otype}
					#{dest_utype} #{active[0]} - #{active[1]}
				"
				@_setOrder order
				@_map.select selected
				@_showOrders()

		@_utypeAbbrev = (type) -> type[0]

		_setOrder: (order) =>
			order = Object.assign {}, text: order, parseOrder(order)
			old_order = @_orders.find (o) -> o.actor is order.actor
			@_orders = @_orders.filter (o) ->
				order.type is MOVE and o.from isnt old_order?.from or
				o.actor isnt order.actor

			@_orders.push order

		_showOrders: ->
			@_map.clearArrows()

			console.log "ORDERS: ", @_orders

			for order in @_orders
				switch order.type
					when MOVE
						@_map.arrow order.from, order.to
					when SUPPORT
						@_map.bind order.from, order.to, order.actor

			# Keep a list of the convoy segments that have already been drawn to
			# keep from overdrawing.
			shown_segs = []
			cunits = for order in @_orders when order.type is CONVOY
				@_board.region(order.actor).unit

			for order in @_orders when order.type is MOVE
				path = @_pfinder.convoyPath order, cunits

				for branch in path
					# Draw the first segment from the source region to the first
					# convoying fleet
					@_map.convoy order.from, branch[0].region

					for i in [0...branch.length]
						unit = branch[i]; next_unit = branch[i+1]
						if next_unit?
							@_map.convoy unit.region, next_unit.region

					console.log branch[branch.length - 1].region, order.to
					# Draw the last convoy segment to the destination
					# @_map.arrow 
					@_map.arrow branch[branch.length - 1].region, order.to

				# Get a list of the path regions. We don't want to draw any of
				# those with the regular triangle stuff because they can be drawn
				# sensibly by the logic above.
				pregions = _.flatten(path).map (u) -> u.region

				for cunit in cunits when cunit.region not in pregions
					@_map.convoy order.from, cunit.region
					@_map.arrow cunit.region, order.to

				console.log "PATH: ", path

	_initBuildControls: ->
		console.log "Init build controls?"
		@_map.on 'select', =>
			console.log "Select fired!!"

module.exports = MapController
