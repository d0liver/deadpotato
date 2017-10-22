$                        = require 'jquery'
gqlQuery                 = require '../gqlQuery'
HorizLinesTextureBuilder = require '../HorizLinesTextureBuilder'
Icons                    = require '../Icons'
RegionTexture            = require '../AreaTexture'
Color                    = require '../../lib/Color'

{GAME_Q, SUBMIT_ORDERS_Q} = require '../gqlQueries'

template       = require '../../views/war-room.pug'
chat_template = require '../../views/war-room-chat.pug'

player_country = null
selected_country = null
selected_country_color = null

class WarRoomController
	constructor: (@_id, @_$el) ->

	# Cannot await on the constructor
	init: ->
		{games: [gdata]} = await gqlQuery GAME_Q, {_id: @_id}
		vdata = gdata.variant
		vdata.map_data = JSON.parse vdata.map_data
		@_$el.html template countries: gdata.phase.countries

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
			$(@).css
				background: "linear-gradient(90deg,#{darker},#{lighter})"
				'border-color': lighter
				cursor: 'pointer'
				position: 'relative'

			$(@).click ->
				return if @ is selected_country?[0]
				lighter = color.copy().darken(30).css()
				darker = color.copy().darken(50).opacity(0.7).css()
				$(@).animate
					background: "linear-gradient(90deg,#{darker},#{lighter})"
					'border-color': lighter
					width: '107%'
					left: '-7%'
				, 200
				$('.right').html chat_template()

				if selected_country?
					lighter = selected_country_color.copy().darken(50).css()
					darker = selected_country_color.copy().darken(70).opacity(0.7).css()
					selected_country.animate
						background: "linear-gradient(90deg,#{darker},#{lighter})"
						'border-color': lighter
						width: '100%'
						position: 'relative'
						left: '0%'
					, 200

				selected_country = $(@)
				selected_country_color = color

module.exports = WarRoomController
