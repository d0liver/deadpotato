VariantUtils = require '../lib/VariantUtils'
Color        = require '../lib/Color'

# Given a TextureBuilder (builds a texture with given dimensions), we will
# generate textures that nicely correspond to the areas.  This way, we can
# accommodate areas which are different colors and which have different
# patterns. This wouldn't be possible otherwise with compositing because we
# would have to make multiple calls to draw to get the different
# colors/patterns which would result in bad things happening after the first
# call (It would apply the compositing to everything on the canvas including
# the stuff that had already been composited in).
AreaTexture = (scanlines, texture_builder) ->
	self = {}
	texture = null
	bnds = null

	init = ->
		bnds = bounds scanlines
		canvas = document.createElement "canvas"
		ctx = canvas.getContext '2d'
		canvas.width = bnds[0].max - bnds[0].min
		canvas.height = bnds[1].max - bnds[1].min

		ctx.strokeStyle = "#000000"
		# First, draw the area onto the canvas in black. This is so that
		# we can source-in the texture next
		fillArea ctx, scanlines, bnds

		ctx.globalCompositeOperation = 'source-in'
		# Next, draw the light texture into the canvas
		{width, height} = ctx.canvas
		texture = texture_builder.render {width, height}
		ctx.drawImage texture, 0, 0

		texture = canvas

		return

	# Draw the texture for the area on the given canvas context
	self.draw = (ctx, state = 'normal') ->
		[dx, dy] = [bnds[0].min, bnds[1].min]
		ctx.drawImage texture, dx, dy

	# Given the scanlines for a area and the bounds of the scanlines, just
	# draw them on the canvas. We don't change any of the settings on the
	# context here, we let the caller set them.
	fillArea = (ctx, scanlines, bnds) ->

		for scanline in scanlines
			{x, y, len} = scanline
			# Translate the scanline to one that's relative to the canvas
			rel_scanline =
				x1: x - bnds[0].min,
				x2: x - bnds[0].min + len,
				y: y - bnds[1].min,
				len: len

			ctx.beginPath()
			ctx.moveTo rel_scanline.x1, rel_scanline.y
			ctx.lineTo rel_scanline.x2, rel_scanline.y
			ctx.stroke()

	# Given a set of scanlines for a area, figure out what the dimensions are
	# of the smallest rectangle that encloses them
	bounds = (scanlines) ->
		# We will use these to store the min and max for x and y
		x = min: Infinity, max: -1
		y = min: Infinity, max: -1

		for {x: sx, y: sy, len: slen} in scanlines
			x.min = Math.min x.min, sx
			x.max = Math.max sx + slen, x.max

			y.min = Math.min sy, y.min
			y.max = Math.max sy, y.max

		[x, y]

	init()
	self

module.exports = AreaTexture
