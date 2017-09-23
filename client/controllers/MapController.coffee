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

	_initControls: ->
		switch @_gavel.phase.season
			when 'Fall', 'Spring'
				new MoveMapControllerStrategy @, @_map, @_board
			when 'Fall Retreat', 'Spring Retreat'
				new RetreatMapControllerStrategy #XXX
			when 'Winter'
				new BuildMapControllerStrategy @, @_map, @_board

module.exports = MapController
