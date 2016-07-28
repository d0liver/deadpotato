window.TextureBuilder = (color_map) ->
	self =
	texture: (width, height, color) ->
		canvas = document.createElement "canvas"
		canvas.width = width
		canvas.height = height
		ctx = canvas.getContext "2d"
		ctx.strokeStyle = color_map.map color

		for i in [0...height] by 4
			ctx.beginPath()
			ctx.moveTo(0, i)
			ctx.lineTo width, i
			ctx.stroke()

		canvas
