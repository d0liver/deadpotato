$                    = require 'jquery'
ColorMap             = require './ColorMap'
GameInfo             = require './GameInfo'
Icons                = require './Icons'
Map                  = require './Map'
RegionTexture        = require './RegionTexture'
RouteHandler         = require './RouteHandler'
Router               = require './Router'
TextureBuilder       = require './TextureBuilder'
UploadVariant        = require './UploadVariant'
cnt                  = require "./cnt"
gam                  = require "./gam"
map                  = require "./map"
rgn                  = require "./rgn"

# Templates
create_game_template = require '../views/create-game.jade'
games_template       = require '../views/games.jade'
board_template       = require '../views/board.jade'

$(document).ready () ->
	upload_variant = UploadVariant cnt, gam, map, rgn
	router = Router()

	router.get '/create': ->
		$container.html create_game_template()
		$container.addClass "text-content"
		$container.html contents
		$(".create-game").one "submit", (e) ->
			e.preventDefault()
			$.post "/save-game", $(".create-game").serialize()
		$(".new-variant").click (e) ->
			e.preventDefault()
			upload_variant.trigger()

	router.get '/games': ->
		$container.html games_template()
		$container.addClass "text-content"
		$body.css 'background-color': "white"
		$(".game .title").text "This is a Test Game"
		$(".game .variant").text "LOTR"
		$(".game .map").attr src: "midearth.bmp"
		country = $(".game .country").remove()
		for val in ["one", "two", "three"]
			$(".game .countries").append country.clone().text val

	router.route()


	$("nav .nav-link").each ->
		fade_in = 0
		$menu = $(this).parent().find ".menu"
		$(@).click (e) ->
			e.preventDefault()
			# method = ["fadeIn", "fadeOut"][fade_in++ & 1]
			$menu.fadeIn 300
		$(@).parent().find(".menu").mouseleave -> $menu.fadeOut 300

	$container = $ '.container'
	$container.html board_template()

	dims = width: 1150, height: 847
	map_img = $("#map-image")[0]
	canvas = $("#map")[0]
	canvas.width = dims.width
	canvas.height = dims.height
    
	canvas = $("#map_select")[0]
	canvas.width = dims.width
	canvas.height = dims.height
    
	ctx = $("#map")[0].getContext '2d'
	color_map = ColorMap()
	select_ctx = $("#map_select")[0].getContext '2d'
	texture_builder = TextureBuilder()
	gam_info = GameInfo rgn, cnt, gam, map_data
	texture_builder = TextureBuilder color_map
	region_textures = RegionTexture gam_info, texture_builder
	region_textures.build()
	map = Map ctx, select_ctx, gam_info, region_textures
	icons = Icons ctx, gam_info
	Set our country. The map will use this to limit our selects, etc.
	map.setCountry "Elves"
	map.showRegions()

	$("#say_hello").submit (e) ->
		e.preventDefault()
		lstatus = $ "#login_status"
		lstatus.text 'Logging in...'
		$.post '/login',
				username: $("#say_hello input[name=username]").value()
				password: $("#say_hello input[name=password]").value()
			,
			->

	# showInteractions gam_info, color_map
	authenticate()

connect_socket = (token) ->
	socket = io '', query: 'token=' + token

	socket
	.on 'connect', () ->
		console.log 'Connected...'
		socket.emit 'chat', "Hello World!", "foo!"
	.on 'disconnect', () ->
		console.log 'Disconnected...'
	.on 'chat', (msg) ->
		console.log "Full circle!: ", msg

authenticate = () ->
	credentials =
		username: "David"
		password: "Foo!"

	$.post('/login').done (result) -> connect_socket result.token

darken = (css_hex, pct_amount) ->
	colors = colorsToArray css_hex

	# Darken the colors
	colors = _.map colors, (color) ->
		amount = color*pct_amount/100 & ~0
		# The Math.min is because we can accept negative values
		Math.min 255, Math.max color - amount, 0

	arrayToColors colors

colorsToArray = (css_hex) ->
	colors = []
	# Remove the leading '#'
	css_hex = css_hex.slice 1

	for i in [1..3]
		# Grab this color
		colors.push parseInt css_hex.slice(0, 2), 16
		# Shrink the string for the next iteration
		css_hex = css_hex.slice 2

	colors

arrayToColors = (colors) ->
	result = ""

	for color in colors
		hex = color.toString(16)
		result += if hex.length is 1 then "0"+hex else hex

	"#"+result

rgbaCssFromHex = (css_hex, alpha) ->
	colors = colorsToArray css_hex
	"rgba("+colors.join(",")+","+alpha+")"

showInteractions = (gam_info, color_map) ->
	countries = gam_info.countries()

	for country in countries
		hex_color = color_map.map country.color.toLowerCase()
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

window.relCoords = (done) ->
	(e) ->
		offset = $(this).offset()
		e.pageX = e.pageX - offset.left
		e.pageY = e.pageY - offset.top

		done e
