# Can accept a color name like 'forest' or a hex value to initialize.
Color = (str) ->
	self = {}
	# The color is represented internally as an rgba array
	rgba = null
	map =
		black: "#000000"
		blue: "#0000ff"
		brown: "#f4a460"
		charcoal: "#36454f"
		crimson: "#800000"
		cyan: "#00ffff"
		forest: "#228b22"
		green: "#00ff00"
		magenta: "#ff00ff"
		navy: "#000080"
		olive: "#808000"
		orange: "#ffa500"
		purple: "#800080"
		red: "#ff0000"
		tan: "#d2b48c"
		teal: "#008080"
		white: "#ffffff"
		yellow: "#ffff00"

	init = ->
		# Grab the rgba value from the hex representation (as an array)
		rgba = hexToRgba if str[0] is '#'
			str
		else
			# We assume that we were given the name of a color and run it through
			# our map
			map[str]

		# If we're given a hex value then the opacity is assumed to be 1.
		rgba.push 1

	self.rgba = -> [rgba...]

	self.name = ->
		value = rgbToHex rgba[0..2]
		for name,val of map when val is value
			return name

	hexToRgba = (css_hex) ->
		colors = []
		# Remove the leading '#'
		css_hex = css_hex.slice 1

		for i in [1..3]
			# Grab this color
			colors.push parseInt css_hex.slice(0, 2), 16
			# Shrink the string for the next iteration
			css_hex = css_hex.slice 2

		colors

	rgbToHex = (colors) ->
		result = ""

		for color in colors
			hex = color.toString(16)
			result += if hex.length is 1 then "0"+hex else hex

		"#"+result

	self.css = (fmt) ->
		if !fmt? or fmt is 'rgba'
			"rgba(#{rgba.join ','})"
		else if fmt is 'hex'
			rgbToHex rgba[0..2]

	self.darken = (pct) ->
		# Element 4 is the opacity - we don't mess with that here. This is an
		# actual color burn.
		rgba[0..2] = (darken c, pct for c in rgba[0..2])
		return self

	self.opacity = (dec) ->
		rgba[3] = dec
		return self

	# TODO: This should actually be fixed. We should be able to initialize with
	# an rgba value.
	self.copy = -> Color self.css 'hex'

	# Darken an rgba component
	darken = (color, pct) ->
		amount = color*pct/100 & ~0
		# The Math.min is because we can accept negative values
		Math.min 255, Math.max color - amount, 0

	init()
	return self

module.exports = Color
