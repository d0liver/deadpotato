$            = require 'jquery'
{parseOrder} = require 'gavel.js'
_            = require 'underscore'

utils                                                = require '../../lib/utils'
{enums: {english, outcomes, orders: eorders, paths}} = require 'gavel.js'
{MOVE, SUPPORT, CONVOY, HOLD}                        = eorders

# These determine what happens when user interacts with the map during
# different phases.
MoveMapControllerStrategy    = require './MoveMapControllerStrategy'
BuildMapControllerStrategy   = require './BuildMapControllerStrategy'
RetreatMapControllerStrategy = require './RetreatMapControllerStrategy'

class MapController

	constructor: (@_gavel, @_board, @_pfinder, @_map, @_gdata, @_vdata) ->
		orders = []
		@_countries = @_gdata.phase.countries; @_regions = @_vdata.map_data.regions

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
		for region from @_board.regions()
			{scanlines, unit_pos, name_pos, name: rname} = region
			@_map.addArea {
				id: rname
				color: region.unit?.country.color ? 'black'
				fill: region.unit?.region in (region.unit?.country.supply_centers ? [])
				icon: region.unit?.type
				name_pos
				unit_pos
				scanlines
			}

		@_map.display()

	orders: -> @_strat.orders

	_initControls: ->
		@_strat = switch @_gavel.phase.season
			when 'Fall', 'Spring'
				new MoveMapControllerStrategy @, @_map, @_board
			when 'Fall Retreat', 'Spring Retreat'
				new RetreatMapControllerStrategy #XXX
			when 'Winter'
				new BuildMapControllerStrategy @, @_map, @_board

module.exports = MapController
