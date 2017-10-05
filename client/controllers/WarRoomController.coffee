$                        = require 'jquery'
gqlQuery                 = require '../gqlQuery'
HorizLinesTextureBuilder = require '../HorizLinesTextureBuilder'
Icons                    = require '../Icons'
RegionTexture            = require '../AreaTexture'
Color                    = require '../../lib/Color'

{GAME_Q, SUBMIT_ORDERS_Q} = require '../gqlQueries'

template = require '../../views/war-room.pug'

player_country = null

class WarRoomController
	self = {}

	constructor: (@_id, @_$el) -> @_init()

	# Cannot await on the constructor
	_init: ->
		{games: [gdata]} = await gqlQuery GAME_Q, {@_id}
		vdata = gdata.variant
		vdata.map_data = JSON.parse vdata.map_data
		$el.html template countries: gdata.phase.countries

		$map = $('<div>').prependTo('.right').gameMap({gdata, vdata}).data('deadpotatoGameMap')

		$('#submit-orders').click ->
			console.log "Submit orders: ", $map.orders()
			gqlQuery SUBMIT_ORDERS_Q, _id: gdata._id, orders: $map.orders()
			# Refresh the page so we can see the new moves
			window.location.reload false


		# Stylize the tabs representing the countries. This needs to be
		# done here because I don't want to inline the styles in the html
		# (nasty to build) and the colors are dynamic so we can't just
		# represent them with SASS.
		$('.tab').each (i) ->
			# These were generated on the other side by iterating them so
			# the order will be the same except that we also have a news
			# tab that comes first, hence i-1
			country = gdata.phase.countries[i-1]
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

module.exports = WarRoomController
