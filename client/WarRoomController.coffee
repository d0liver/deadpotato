$                        = require 'jquery'
Q                        = require 'q'
co                       = require 'co'
h                        = require 'virtual-dom/h'

gqlQuery                   = require './gqlQuery'
HorizLinesTextureBuilder   = require './HorizLinesTextureBuilder'
Icons                      = require './Icons'
RegionTexture              = require './RegionTexture'
Color                      = require '../lib/Color'

player_country = null

WarRoomController = (_id, view) ->
	self = {}

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
			# player_country = gdata.player_country
			vdata.map_data = JSON.parse vdata.map_data

			$('<div>').prependTo('.right').gameMap {gdata, vdata}

			# $('#submit-orders').click ->
			# 	console.log "Submit orders: ", map_controller.orders()
			# 	gqlQuery """
			# 		mutation submitOrders($_id: ObjectID, $orders: [String]) {
			# 			submitOrders(_id: $_id, orders: $orders)
			# 		}
			# 	""", orders: map_controller.orders(), _id: gdata._id


			# Stylize the tabs representing the countries. This needs to be done here
			# because I don't want to inline the styles in the html (nasty to build)
			# and the colors are dynamic so we can't just represent them with SASS.
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

	init()
	return self

module.exports = WarRoomController
