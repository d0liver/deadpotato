$                        = require 'jquery'
Q                        = require 'q'
co                       = require 'co'
h                        = require 'virtual-dom/h'

gqlQuery                   = require './gqlQuery'
{Gavel, Board, PathFinder} = require '/home/david/gavel/'
Map                        = require './Map'
MapController              = require './MapController'
HorizLinesTextureBuilder   = require './HorizLinesTextureBuilder'
Icons                      = require './Icons'
MapIcon                    = require '../lib/MapIcon'
RegionTexture              = require './RegionTexture'
Color                      = require '../lib/Color'

player_country = null

Game = (_id, view) ->
	self = {}
	vdata = null; gdata = null; map_controller = null
	console.log "Initializing game..."

	init = ->
		co ->
			{data: {findGame: gdata}} = yield Q gqlQuery """
				query findGame($_id: ObjectID!) {
					findGame(_id: $_id) {
						_id
						title
						player_country
						season_year
						players {
							pid
							country
						}
						countries {
							adjective
							color
							name
							pattern
							supply_centers
							units {
								type
								region
								coast
							}
						}
						variant {
							map_data
							name
							slug
							assets
						}
					}
				}
			""", {_id}
			console.log "Game: ", gdata
			vdata = gdata.variant
			stylizeTabs()
			player_country = gdata.player_country
			console.log "Player country: ", gdata.player_country
			vdata.map_data = JSON.parse vdata.map_data
			mapSetup.call $('.root')[0], vdata

			$('#submit-orders').click ->
				console.log "Submit orders: ", map_controller.orders()
				gqlQuery """
					mutation submitOrders($_id: ObjectID, $orders: [String]) {
						submitOrders(_id: $_id, orders: $orders)
					}
				""", orders: map_controller.orders(), _id: gdata._id


	# Stylize the tabs representing the countries. This needs to be done here
	# because I don't want to inline the styles in the html (nasty to build)
	# and the colors are dynamic so we can't just represent them with SASS.
	stylizeTabs = ->
		$('.tab').each (i) ->
			# These were generated on the other side by iterating them so the
			# order will be the same.
			country = gdata.countries[i]
			# Start at 100% opaque and fade to 70%
			color = Color(country.color.toLowerCase())
			lighter = color.copy().darken(50).css()
			darker = color.copy().darken(70).opacity(0.7).css()
			$(this).css
				background: "linear-gradient(90deg,#{darker},#{lighter})"
				'border-color': lighter

	mapSetup = ->
		$this = $(@)
		getContext = (id) -> $this.find("##{id}")[0].getContext '2d'

		ctx =
			map: getContext 'map'
			arrow: getContext 'arrow'
			icon: getContext 'icon'

		# THIS MUST EXIST. The browser is not smart enough to use the CSS width
		# and height for the canvas (it will scale it like an image rather than
		# actually setting the canvas dimensions). So, if you want to size it
		# with css (which seems reasonable) then you must dig up the CSS
		# properties and manually set them on the canvas.
		for k,c of ctx
			$map_image = $ '#map-image'
			width = $map_image.innerWidth()
			height = $map_image.innerHeight()
			$(c.canvas).css 'width', width; $(c.canvas).css 'height', height
			c.canvas.width = width; c.canvas.height = height

		console.log "Variant info: ", vdata
		# New Map constructor that only takes the regions - needed for map
		# creation in the controller (it's better to have the business logic
		# for the regions there).
		board = Board gdata, vdata
		pfinder = PathFinder board
		gavel = Gavel board
		map = Map ctx, MapIcon.bind null, vdata.slug, vdata.assets
		map_controller = MapController board, pfinder, map, gdata, vdata

	init()
	return self

module.exports = Game
