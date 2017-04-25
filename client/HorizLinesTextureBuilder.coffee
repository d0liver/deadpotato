HorizLinesTextureBuilder = ({color, byy = 4})->
	self.render = ({width, height}) ->
		canvas = document.createElement "canvas"
		canvas.width = width
		canvas.height = height
		ctx = canvas.getContext "2d"
		ctx.strokeStyle = color.value()

		for i in [0...height] by byy
			ctx.beginPath()
			ctx.moveTo(0, i)
			ctx.lineTo width, i
			ctx.stroke()

		canvas

	return self

module.exports = HorizLinesTextureBuilder
