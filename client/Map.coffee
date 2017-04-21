Map = (ctx, select_ctx, gam_info, region_textures) ->
	country = selected_region = null

	self = 
	setCountry: (c) -> country = c

	# Get the region that the event is over or null if it's not over a region.
	evtRegion: (e) ->
		[x, y] = [e.pageX, e.pageY]

		# Search through the scanlines and figure out if we're on one of them.
		# If so, return the name of that region.
		_.findKey gam_info.rgns(), (region) ->
			region.scanlines.find (scanline) ->
				{x: sx, y: sy, len: slen} = scanline
				y is sy and sx < x < sx + slen

	darkenRegion: (region_name) ->
		return if not region_name

		canvas = select_ctx.canvas
		scanlines = gam_info.regionScanLines region_name, true

		ctx.strokeStyle = "#000000"
		select_ctx.beginPath()
		for scanline in scanlines
			{x, y, len} = scanline
			select_ctx.moveTo x, y
			select_ctx.lineTo x + len, y
			select_ctx.stroke()

	# Draw all of the regions from all of the countries on the map
	showRegions: () ->
		supply_centers = gam_info.countrySupplyCenters()

		for country_centers in supply_centers
			for country in country_centers
				region_textures.draw ctx, country

	# Draw an arrow from one region1 to region2
	arrow: (region1, region2) ->
		triangle_side = 10
		r1_coords = gam_info.unitPos region1
		r2_coords = gam_info.unitPos region2
		scale = 6

		# First draw the line connecting the regions
		ctx.beginPath()
		ctx.moveTo r1_coords.x, r1_coords.y
		ctx.lineTo r2_coords.x, r2_coords.y
		ctx.stroke()

		# Then draw the arrow at the tip of the line. We want to draw an
		# isosceles triangle whose bottom edge is centered on r2_coords.
		ctx.translate r2_coords.x, r2_coords.y
		angle = Math.PI - Math.atan2 \
			r2_coords.x - r1_coords.x,
			r2_coords.y - r1_coords.y
		ctx.rotate angle
		ctx.beginPath()
		# Bottom left corner
		ctx.moveTo -scale, 2*scale
		# Bottom right corner
		ctx.lineTo scale, 2*scale
		# Top corner
		ctx.lineTo 0, 0
		ctx.closePath()
		ctx.fill()
		ctx.setTransform 1, 0, 0, 1, 0, 0

		# Now, draw the circle from the origin
		ctx.arc r1_coords.x, r1_coords.y, scale, 0, Math.PI*2, true
		ctx.fill()

	select: (e) ->
		canvas = select_ctx.canvas
		new_select = self.evtRegion e

		# Was a valid first region selected?
		if not selected_region and \
		(
			not country or
			(
				(sel_country = gam_info.country new_select) and
				sel_country.name is country
			)
		)
			selected_region = new_select
			# This is the first region selected, we darken it and wait for the user
			# to select a second region
			self.darkenRegion selected_region
		# Is this the second region? (Could be an invalid first region)
		else if selected_region
			# Draw the arrow, reset the selector and clear the darkened region
			self.arrow selected_region, new_select
			selected_region = null
			select_ctx.clearRect 0, 0, canvas.width, canvas.height

	clearRegions: (e) ->

	selected_region = null
	# The country of the current player
	country = null

	$(select_ctx.canvas).click relCoords self.select

	self

module.exports = Map
