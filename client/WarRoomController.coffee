$                        = require 'jquery'
Q                        = require 'q'
co                       = require 'co'
gqlQuery                   = require './gqlQuery'
HorizLinesTextureBuilder   = require './HorizLinesTextureBuilder'
Icons                      = require './Icons'
RegionTexture              = require './RegionTexture'
Color                      = require '../lib/Color'

{GAME_Q} = require './gqlQueries'

template = require '../views/war-room.pug'

player_country = null

WarRoomController = (_id, $el) ->
	self = {}

	init = ->
		co ->
			{games: [gdata]} = yield gqlQuery GAME_Q, {_id}
			vdata = gdata.variant
			# player_country = gdata.player_country
			vdata.map_data = JSON.parse vdata.map_data
			$el.html template countries: gdata.countries

			$('<div>').prependTo('.right').gameMap {gdata, vdata}

			# $('#submit-orders').click ->
			# 	console.log "Submit orders: ", map_controller.orders()
			# 	gqlQuery """
			# 		mutation submitOrders($_id: ObjectID, $orders: [String]) {
			# 			submitOrders(_id: $_id, orders: $orders)
			# 		}
			# 	""", orders: map_controller.orders(), _id: gdata._id


			# Stylize the tabs representing the countries. This needs to be
			# done here because I don't want to inline the styles in the html
			# (nasty to build) and the colors are dynamic so we can't just
			# represent them with SASS.
			$('.tab').each (i) ->
				# These were generated on the other side by iterating them so
				# the order will be the same except that we also have a news
				# tab that comes first, hence i-1
				country = gdata.countries[i-1]
				# Start at 100% opaque and fade to 70%
				if country?.color?
					color = Color(country.color.toLowerCase())
				else
					color = Color 'black'

				lighter = color.copy().darken(50).css()
				darker = color.copy().darken(70).opacity(0.7).css()
				$(this).css
					background: "linear-gradient(90deg,#{darker},#{lighter})"
					'border-color': lighter

	init()
	return self

module.exports = WarRoomController
