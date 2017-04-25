# Can accept a color name like 'forest' or a hex value to initialize.
Color = (str) ->
	self = {}
	rgba = null; value = null
	map =
		forest: "#228b22"
		charcoal: "#36454f"
		red: "#ff0000"
		brown: "#f4a460"
		teal: "#008080"
		blue: "#0000ff"
		orange: "#ffa500"
		navy: "#000080"

	init = ->
		rgba = colorsToArray if str[0] is '#'
			str
		else
			# We assume that we were given the name of a color and run it through
			# our map
			map[str]

	self.value = -> arrayToColors rgba

	self.name = ->
		value = arrayToColors rgba
		for name,val of map when val is value
			return name

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

	self.darken = (pct) ->
		rgba = (darken c, pct for c in rgba)
		return self

	self.copy = ->
		return Color self.value()

	# Darken an rgba component
	darken = (color, pct) ->
		amount = color*pct/100 & ~0
		# The Math.min is because we can accept negative values
		Math.min 255, Math.max color - amount, 0

	init()
	return self

module.exports = Color
