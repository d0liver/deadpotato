$                        = require 'jquery'
Q                        = require 'q'
co                       = require 'co'
h                        = require 'virtual-dom/h'

gqlQuery                 = require './gqlQuery'
Gavel                    = require '/home/david/gavel'
Map                      = require './Map'
MapController            = require './MapController'
HorizLinesTextureBuilder = require './HorizLinesTextureBuilder'
Icons                    = require './Icons'
MapIcon                  = require '../lib/MapIcon'
RegionTexture            = require './RegionTexture'
Color                    = require '../lib/Color'

player_country = null

Game = (_id, view) ->
	self = {}
	vdata = null
	console.log "Initializing game..."

	init = ->
		co ->
			{data: {findGame: game}} = yield Q gqlQuery """
				query findGame($_id: ObjectID!) {
					findGame(_id: $_id) {
						_id
						title
						player_country
						players {
							pid
							country
						}
						variant {
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
							map_data
							name
							season_year
							slug
							assets
						}
					}
				}
			""", {_id}
			console.log "Game: ", game
			vdata = game.variant
			stylizeTabs()
			player_country = game.player_country
			console.log "Player country: ", game.player_country
			Object.assign vdata, JSON.parse vdata.map_data
			mapSetup.call $('.root')[0], vdata

	# Stylize the tabs representing the countries. This needs to be done here
	# because I don't want to inline the styles in the html (nasty to build)
	# and the colors are dynamic so we can't just represent them with SASS.
	stylizeTabs = ->
		$('.tab').each (i) ->
			# These were generated on the other side by iterating them so the
			# order will be the same.
			country = vdata.countries[i]
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
			width = parseInt $(c.canvas).css 'width'
			height = parseInt $(c.canvas).css 'height'
			c.canvas.width = width; c.canvas.height = height

		console.log "Variant info: ", vdata
		# New Map constructor that only takes the regions - needed for map
		# creation in the controller (it's better to have the business logic
		# for the regions there).
		gavel = Gavel vdata
		map = Map ctx, MapIcon.bind null, vdata.slug, vdata.assets
		map_controller = MapController gavel, map, vdata

	init()
	return self

module.exports = Game
