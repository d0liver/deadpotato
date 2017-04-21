# Given a TextureBuilder (builds a texture with given dimensions, we will
# generate textures that nicely correspond to the regions given from the
# GameInfo . This way, we can accommodate regions which are different colors
# and which have different patterns. This wouldn't be possible otherwise with
# compositing because we would have to make multiple calls to draw to get the
# different colors/patterns which would result in bad things happening after
# the first call (It would apply the compositing to everything on the canvas
# including the stuff that had already been composited in).
RegionTexture = (gam_info, texture_builder) ->
	self = {}
	textures = null

	# This must be called before the caller actually tries to get any textures
	# from us
	self.build = () ->
		rgns = gam_info.rgns()
		textures = {}

		for region of rgns
			bnds = bounds rgns[region].scanlines
			textures[region] = 
				img: buildRegionTexture \
					rgns[region].scanlines,
					bnds,
					gam_info.regionColor(region)
				,
				bounds: bnds

	# Draw the texture for the region on the given canvas context
	draw = (ctx, region_name) ->
		if not textures
			throw new Error "Textures were referenced before being built."
		texture = textures[region_name]

		ctx.drawImage \
			texture.img,
			texture.bounds.x.min,
			texture.bounds.y.min

	buildRegionTexture = (scanlines, bnds, color) ->
		canvas = document.createElement "canvas"
		ctx = canvas.getContext '2d'
		canvas.width = bnds[0].max - bnds[1].min
		canvas.height = bnds[0].max - bnds[1].min

		ctx.strokeStyle = "#000000"
		# First, draw the region onto the canvas in black. This is so that
		# we can source-in the texture next
		fillRegion ctx, scanlines, bnds

		ctx.globalCompositeOperation = 'source-in'
		# Next, draw the texture into the canvas
		texture = texture_builder.texture \
			ctx.canvas.width, ctx.canvas.height, color
		ctx.drawImage texture, 0, 0

		canvas

	# Given the scanlines for a region and the bounds of the scanlines, just
	# draw them on the canvas. We don't change any of the settings on the
	# context here, we let the caller set them.
	fillRegion = (ctx, scanlines, bnds) ->

		for scanline in scanlines
			{x, y, len} = scanline
			{min, max} = bnds
			# Translate the scanline to one that's relative to the canvas
			rel_scanline =
				x1: x - min,
				x2: x - min + len,
				y: y - min,
				len: len

			ctx.beginPath()
			ctx.moveTo rel_scanline.x1, rel_scanline.y
			ctx.lineTo rel_scanline.x2, rel_scanline.y
			ctx.stroke()

	# Given a set of scanlines for a region, figure out what the dimensions are
	# of the smallest rectangle that encloses them
	bounds = (scanlines) ->
		# We will use these to store the min and max for x and y
		x = JSON.parse(JSON.stringify(y = min: Infinity, max: -1))

		for {x: sx, y: sy, len: slen} in scanlines
			x.min = Math.min x.min, sx
			x.max = Math.max sx + slen, x.max

			y.min = Math.min sy, y.min
			y.max = Math.max sy, y.max

		[x, y]

	self

module.exports = RegionTexture
