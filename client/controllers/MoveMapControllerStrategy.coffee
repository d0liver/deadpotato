_ = require 'underscore'
$ = require 'jquery'

{parseOrder}         = require 'gavel.js'
KeyboardInputHandler = require '../KeyboardInputHandler'

{enums: {english, outcomes, orders: eorders, paths}} = require 'gavel.js'
{MOVE, SUPPORT, CONVOY, HOLD}                        = eorders

# Input controls for the regular phases (Fall and Spring)
class MoveMapControllerStrategy

	constructor: (@_map_controller, @_map, @_gavel) ->
		@_orders = []
		Object.defineProperty @, 'orders', get: -> @_orders.map (o) -> o.text
		kiph = new KeyboardInputHandler

		@_map.on 'select', ({id: sel_id}) =>
			region = (r) => @_gavel.board.region(r)
			selected = region sel_id
			# Get a list of the active ids
			active = @_map.active
			# Get the underlying regions for the active selections
			a0 = region active[0]; a1 = region active[1]

			# It's not valid for the first selection to be a region without a
			# unit. The second selection is, in fact, the only selection that
			# it's valid to do on a region without a unit (since it's the
			# destination of a move)
			# Furthermore, the initial selection must be on a unit that we own.
			unless (selected.unit? or active.length is 1) and
			(active.length isnt 0 or selected.unit?.country.name is @_gavel.country)
				@_map.clearActive()
				return

			# Initial selection
			if active.length is 0
				@_map.select sel_id
			# Select a destination region for the move
			else if active.length is 1 and sel_id isnt active[0]
				utype = a0.unit.type
				country = a0.unit.country.name
				order = "#{country}: #{@_utypeAbbrev utype} #{active[0]} - #{sel_id}"
				@_setOrder order
				@_map.select sel_id
				@_showOrders()
			# Either support or convoy active[0] depending on if a modifier key has
			# been pressed.
			else if active.length > 1
				utype = selected.unit.type
				country = selected.unit.country.name
				dest_utype = @_utypeAbbrev a0.unit.type
				otype = (kiph.shiftIsDown or kiph.ctrlIsDown) and 'Convoys' or 'Supports'
				order = "
					#{country}: #{@_utypeAbbrev utype} #{selected} #{otype}
					#{dest_utype} #{active[0]} - #{active[1]}
				"
				@_setOrder order
				@_map.select sel_id
				@_showOrders()

		@_utypeAbbrev = (type) -> type[0]

		$(document).on 'keydown', =>
			if kiph.escIsDown
				@_map.clearActive()

	_setOrder: (order) ->
		order = Object.assign {}, text: order, parseOrder(order)
		old_order = @_orders.find (o) -> o.actor is order.actor
		@_orders = @_orders.filter (o) ->
			order.type is MOVE and o.from isnt old_order?.from or
			o.actor isnt order.actor

		console.log "Try to add order: ", order.text
		if @_gavel.isLegal order.text
			console.log "Adding order: ", order
			@_orders.push order
		# TODO: How should we handle attempts at inputting invalid orders?
		# Currently nothing happens. Maybe there should be some kind of
		# indicator that pops up?
		# else

	_showOrders: ->
		@_map.clearArrows()

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
			@_gavel.board.region(order.actor).unit

		for order in @_orders when order.type is MOVE
			path = @_gavel.pfinder.convoyPath order, cunits

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

module.exports = MoveMapControllerStrategy
