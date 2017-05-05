$                        = require 'jquery'
h                        = require 'virtual-dom/h'
gqlQuery                 = require './gqlQuery'
Q                        = require 'q'
co                       = require 'co'
Engine                   = require '../lib/Engine'
Icons                    = require './Icons'
Map                      = require './Map'
MapController            = require './MapController'
MapIcon                  = require '../lib/MapIcon'
RegionTexture            = require './RegionTexture'
HorizLinesTextureBuilder = require './HorizLinesTextureBuilder'

player_country = null

showInteractions = (gam_info, color_map) ->
	countries = gam_info.countries()

	for country in countries
		hex_color = color_map.map country.color
		color = darken hex_color, 50
		gradient_dark = darken hex_color, 70
		text_color = darken hex_color, -20
		$(".interactions ul").append \
			"<li style='
				border-color: #{color};
				border-bottom: solid black 1px;
				background: linear-gradient(90deg, #{rgbaCssFromHex(gradient_dark, 1)}, #{rgbaCssFromHex(color, 0.7)});
			'>
			<span style='color: white;' class='label'>
				#{country.name}
			</span>
			<span class='interaction-icon'><i class='fa fa-envelope'></i></span>
			<span class='interaction-icon'><i class='fa fa-flag'></i></span>
			<span class='interaction-icon'><i class='fa fa-gears'></i></span>"

Game = (_id, view) ->
	self = {}
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
						}
					}
				}
			""", {_id}
			console.log "Game: ", game
			variant_data = game.variant
			player_country = game.player_country
			console.log "Player country: ", game.player_country
			Object.assign variant_data, JSON.parse variant_data.map_data
			display variant_data

	mapSetup = (variant_data) ->
		$this = $(@)
		getContext = (id) -> $this.find("##{id}")[0].getContext '2d'

		ctx =
			map: getContext 'map'
			arrow: getContext 'arrow'
			icon: getContext 'icon'

		console.log "Variant info: ", variant_data
		# New Map constructor that only takes the regions - needed for map
		# creation in the controller (it's better to have the business logic
		# for the regions there).
		engine = Engine variant_data, player_country
		map = Map ctx, MapIcon.bind null, variant_data.slug
		map_controller = MapController engine, map, variant_data

	display = (variant_data) ->
		S3_BUCKET = "https://s3.us-east-2.amazonaws.com/deadpotato/"
		canvas_dims = width: 1150, height: 847

		view.display h '.root', style: 'position: relative', [
			h 'img#map-image', src: "#{S3_BUCKET}#{variant_data.slug}/map.bmp"
			h 'canvas',
				id: 'map'
				width: canvas_dims.width
				height: canvas_dims.height
				style: 'position: absolute; top: 0; left: 0'
			h 'canvas',
				id: 'arrow'
				style: 'position: absolute; top: 0; left: 0'
				width: canvas_dims.width
				height: canvas_dims.height
			h 'canvas',
				id: 'icon'
				style: 'position: absolute; top: 0; left: 0'
				width: canvas_dims.width
				height: canvas_dims.height
			h 'button.submit-orders',
				id: 'submit-orders'
			, 'Submit Orders'
		]

		mapSetup.call $('.root')[0], variant_data

	init()
	return self

module.exports = Game
