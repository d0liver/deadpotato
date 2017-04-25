h   = require 'virtual-dom/h'

color_map =
	forest: "#228b22"
	charcoal: "#36454f"
	red: "#ff0000"
	brown: "#f4a460"
	teal: "#008080"
	blue: "#0000ff"
	orange: "#ffa500"
	navy: "#000080"

# Darken the colors
darken = (color, pct_amount) ->
	amount = color*pct_amount/100 & ~0
	# The Math.min is because we can accept negative values
	Math.min 255, Math.max color - amount, 0

colors = Object.values color_map

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

relCoords = (done) ->
	(e) ->
		offset = $(this).offset()
		e.pageX = e.pageX - offset.left
		e.pageY = e.pageY - offset.top

		done e

arrayToColors colors

module.exports = ({img}) ->
	canvas_dims = width: 1150, height: 847
	init = ->
		console.log "Root loaded"
		$this           = $(@)
		ctx             = $this.find('#map')[0].getContext '2d'
		select_ctx      = $this.find("#map-select")[0].getContext '2d'
		color_map       = ColorMap()
		texture_builder = TextureBuilder()
		gam_info        = GameInfo rgn, cnt, gam, map_data
		texture_builder = TextureBuilder color_map
		region_textures = RegionTexture gam_info, texture_builder
		map             = Map ctx, select_ctx, gam_info, region_textures
		icons           = Icons ctx, gam_info

		region_textures.build()

		# Set our country. The map will use this to limit our selects, etc.
		map.setCountry "Elves"
		map.showRegions()

	h '.root', onload: init, [
		h 'img#map-image', src: img
		h 'canvas#map', canvas_dims
		h 'canvas#map-select', canvas_dims
	]
