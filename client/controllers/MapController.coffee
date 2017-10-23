# These determine what happens when user interacts with the map during
# different phases.
MoveMapControllerStrategy    = require './MoveMapControllerStrategy'
BuildMapControllerStrategy   = require './BuildMapControllerStrategy'
RetreatMapControllerStrategy = require './RetreatMapControllerStrategy'

class MapController

	constructor: (@_gavel, @_map) ->
		orders = []

		@_initMap()
		@_initControls()

	_initMap: ->

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
		for region from @_gavel.board.regions()
			{scanlines, unit_pos, name_pos, name: rname} = region
			# Sub zones (e.g. coastal areas) can also be added to the map for
			# sub selection.
			zones = {}

			for name, coast of region.coasts
				zones[name] =
					scanlines: coast.scanlines
					unit_pos: coast.unit_pos
					id: name

			@_map.addArea {
				id: rname
				unit_color: region.unit?.country.color
				dislodged_unit_color: region.dislodged_unit?.country.color
				color: @_gavel.board.countryOwns(rname)?.color
				fill: @_gavel.board.countryOwns(rname)?
				icon: region.unit?.type
				offset_icon: region.dislodged_unit?.type
				name_pos
				unit_pos
				scanlines
				zones
			}

		@_map.display()

	orders: -> @_strat.orders

	_initControls: ->
		@_strat = switch @_gavel.phase.season
			when 'Fall', 'Spring'
				new MoveMapControllerStrategy @, @_map, @_gavel
			when 'Fall Retreat', 'Spring Retreat'
				new RetreatMapControllerStrategy #XXX
			when 'Winter'
				new BuildMapControllerStrategy @, @_map, @_gavel

module.exports = MapController
