# We use the scanlines provided to draw a box around each of the countries and
# get a little icon for their area

window.Icons = (ctx, gam_info) ->
	# An array of canvases with the icons drawn on them
	icons = []

	supply_centers = gam_info.countrySupplyCenters()
	rgns = gam_info.rgns()

	for country in supply_centers
		bounds =
			x_min: Infinity
			y_min: Infinity
			x_max: -1
			y_max: -1

		for center in supply_centers
			for scanline in gam_info.regionScanLines center, true
				bounds.x_min = Math.min bounds.x_min, scanline.x
				bounds.x_max = Math.max bounds.x_max, scanline.x
				bounds.y_min = Math.min bounds.y_min, scanline.y
				bounds.y_max = Math.max bounds.y_max, scanline.y

		bbox_width = bounds.x_max - bounds.x_min
		bbox_height = bounds.y_max - bounds.y_min
		ratio = bbox_width/bbox_height

		icon_canvas = document.createElement "canvas"
		icon_ctx = icon_canvas.getContext '2d'
		icon_canvas.height = 150
		icon_canvas.width = 150

		# Force the canvas to fit in a 150 by 150 icon
		if bbox_width > bbox_height
			dest_width = 150
			dest_height = 150/ratio
		else
			dest_height = 150
			dest_width = 150*ratio

		icon_ctx.drawImage \
			ctx.canvas,
			bounds.x_min,
			bounds.y_min,
			bbox_width,
			bbox_height,
			0,
			0,
			dest_width,
			dest_height

		icons.push canvas: icon_canvas, country: country

	self = icons: () -> icons
