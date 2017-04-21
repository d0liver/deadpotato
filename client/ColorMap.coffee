ColorMap = () ->
	map = 
		forest: "#228b22"
		charcoal: "#36454f"
		red: "#ff0000"
		brown: "#f4a460"
		teal: "#008080"
		blue: "#0000ff"
		orange: "#ffa500"
		navy: "#000080"

	self =
		map: (color) -> map[color]

module.exports = ColorMap
