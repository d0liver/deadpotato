$(document).ready () ->
	rh = RouteHandler()
	upload = UploadVariant()
	Aviator.setRoutes
		'/board':
			target: rh
			'/': 'board'
		'/upload-variant':
			target: rh
			'/': 'uploadVariant'

	Aviator.dispatch()
	# dims = width: 1150, height: 847
	# map_img = $("#map-image")[0]
	# canvas = $("#map")[0]
	# canvas.width = dims.width
	# canvas.height = dims.height
    #
	# canvas = $("#map_select")[0]
	# canvas.width = dims.width
	# canvas.height = dims.height
    #
	# ctx = $("#map")[0].getContext '2d'
	# color_map = ColorMap()
	# select_ctx = $("#map_select")[0].getContext '2d'
	# texture_builder = TextureBuilder()
	# gam_info = GameInfo rgns, cnt, gam, map_data
	# texture_builder = TextureBuilder color_map
	# region_textures = RegionTexture gam_info, texture_builder
	# region_textures.build()
	# map = Map ctx, select_ctx, gam_info, region_textures
	# icons = Icons ctx, gam_info
	# Set our country. The map will use this to limit our selects, etc.
	# map.setCountry "Elves"
	# map.showRegions()

# 	$("#say_hello").submit (e) ->
# 		e.preventDefault()
# 		lstatus = $ "#login_status"
# 		lstatus.text 'Logging in...'
# 		$.post '/login',
# 				username: $("#say_hello input[name=username]").value()
# 				password: $("#say_hello input[name=password]").value()
# 			,
# 			->
#
# 	# showInteractions gam_info, color_map
# 	authenticate()
#
# connect_socket = (token) ->
# 	socket = io '', query: 'token=' + token
#
# 	socket
# 	.on 'connect', () ->
# 		console.log 'Connected...'
# 		socket.emit 'chat', "Hello World!", "foo!"
# 	.on 'disconnect', () ->
# 		console.log 'Disconnected...'
# 	.on 'chat', (msg) ->
# 		console.log "Full circle!: ", msg
#
# authenticate = () ->
# 	credentials =
# 		username: "David"
# 		password: "Foo!"
#
# 	$.post('/login').done (result) -> connect_socket result.token
#
# darken = (css_hex, pct_amount) ->
# 	colors = colorsToArray css_hex
#
# 	# Darken the colors
# 	colors = _.map colors, (color) ->
# 		amount = color*pct_amount/100 & ~0
# 		# The Math.min is because we can accept negative values
# 		Math.min 255, Math.max color - amount, 0
#
# 	arrayToColors colors
#
# colorsToArray = (css_hex) ->
# 	colors = []
# 	# Remove the leading '#'
# 	css_hex = css_hex.slice 1
#
# 	for i in [1..3]
# 		# Grab this color
# 		colors.push parseInt css_hex.slice(0, 2), 16
# 		# Shrink the string for the next iteration
# 		css_hex = css_hex.slice 2
#
# 	colors
#
# arrayToColors = (colors) ->
# 	result = ""
#
# 	for color in colors
# 		hex = color.toString(16)
# 		result += if hex.length is 1 then "0"+hex else hex
#
# 	"#"+result
#
# rgbaCssFromHex = (css_hex, alpha) ->
# 	colors = colorsToArray css_hex
# 	"rgba("+colors.join(",")+","+alpha+")"
#
# showInteractions = (gam_info, color_map) ->
# 	countries = gam_info.countries()
#
# 	for country in countries
# 		hex_color = color_map.map country.color.toLowerCase()
# 		color = darken hex_color, 50
# 		gradient_dark = darken hex_color, 70
# 		text_color = darken hex_color, -20
# 		$(".interactions ul").append \
# 			"<li style='
# 				border-color: #{color};
# 				border-bottom: solid black 1px;
# 				background: linear-gradient(90deg, #{rgbaCssFromHex(gradient_dark, 1)}, #{rgbaCssFromHex(color, 0.7)});
# 			'>
# 			<span style='color: white;' class='label'>
# 				#{country.name}
# 			</span>
# 			<span class='interaction-icon'><i class='fa fa-envelope'></i></span>
# 			<span class='interaction-icon'><i class='fa fa-flag'></i></span>
# 			<span class='interaction-icon'><i class='fa fa-gears'></i></span>"
#
# window.relCoords = (done) ->
# 	(e) ->
# 		offset = $(this).offset()
# 		e.pageX = e.pageX - offset.left
# 		e.pageY = e.pageY - offset.top
#
# 		done e
