$                        = require 'jquery'
VariantUtils             = require '../lib/VariantUtils'
Color                    = require '../lib/Color'
co                       = require 'co'
RegionTexture            = require './RegionTexture'
HorizLinesTextureBuilder = require './HorizLinesTextureBuilder'
Emitter                  = require '../lib/Emitter'

Map = (ctx, MapIcon) ->
	self = {}
	# Used to scale up and down arrows and binds
	scale = 6
	emitter = Emitter()
	active = []
	regions = {}
	# Map the normal region color to the one that we will use for a particular
	# state
	state_colors =
		normal: (color) -> color
		active: (color) -> color.copy().darken 70

	self.on = emitter.on

	self.addRegion = (id, region) ->
		if region.color then region.color = Color region.color
		region.texture = {}
		# We also save the id on the region to make working with them
		# internally easier (we can pass around regions by reference here but
		# don't have to do a lookup when getting the id for external
		# interactions)
		region.id = id
		regions[id] = region

	self.clearActive = ->
		active = []
		self.refresh()

	self.clearArrows = -> clearCanvas ctx.arrow

	# Get the region that the event is over or null if it's not over a region.
	self.evtRegion = (e) ->
		[x, y] = [e.pageX, e.pageY]

		for id, region of regions
			for scanline in region.scanlines
				{x: sx, y: sy, len: slen} = scanline
				if y is sy and sx < x < sx + slen
					return {id, region}
		return

	self.display = -> self.refresh false

	# Redraw everything on the map. Note that if clear is false then we can
	# skip the initial canvas clear (i.e. display instead of refresh).
	self.refresh = (clear = true)->
		clearCanvas ctx.map if clear
		for id,region of regions when region.color?
			# Draw the fill first
			state =
				if region.id in active then 'active'
				else 'normal'
			self.showRegion region, state: state, refresh: false

		return self

	self.showRegion = (region, {state = 'normal', refresh = true}) ->
		unless region.texture[state]
			{scanlines, color} = region
			tb = HorizLinesTextureBuilder color: state_colors[state] color
			region.texture[state] = RegionTexture scanlines, tb

		region.texture[state].draw ctx.map
		self.showIcon region

	self.showIcon = co.wrap (region) ->
		img = yield MapIcon(region.color, region.icon).img()
		[x, y] = region.unit_pos
		# The given positions are for the center of the image so we have to
		# subtract half since our coords are for top left
		ctx.icon.drawImage img, x - 16, y - 16, 32, 32

		return self

	# Draw an arrow from one region1 to region2
	self.arrow = (id1, id2) ->
		triangle_side = 10
		r1_coords = regions[id1].unit_pos
		r2_coords = regions[id2].unit_pos
		ctx.arrow.strokeStyle = ctx.arrow.fillStyle = regions[id1].color.value()

		# First draw the line connecting the regions
		ctx.arrow.beginPath()
		ctx.arrow.moveTo r1_coords[0], r1_coords[1]
		ctx.arrow.lineTo r2_coords[0], r2_coords[1]
		ctx.arrow.stroke()

		# Then draw the arrow at the tip of the line. We want to draw an
		# isosceles triangle whose bottom edge is centered on r2_coords.
		ctx.arrow.translate r2_coords[0], r2_coords[1]
		angle = Math.PI - Math.atan2 \
			r2_coords[0] - r1_coords[0],
			r2_coords[1] - r1_coords[1]
		ctx.arrow.rotate angle
		ctx.arrow.beginPath()
		# Bottom left corner
		ctx.arrow.moveTo -scale, 2*scale
		# Bottom right corner
		ctx.arrow.lineTo scale, 2*scale
		# Top corner
		ctx.arrow.lineTo 0, 0
		ctx.arrow.closePath()
		ctx.arrow.fill()
		ctx.arrow.setTransform 1, 0, 0, 1, 0, 0

		return self

	# Draw a line from a unit to intersect with the line of another arrow. Used
	# to indicate support
	self.bind = (id1, id2, id3) ->
		r1_coords = regions[id1].unit_pos
		r2_coords = regions[id2].unit_pos
		r3_coords = regions[id3].unit_pos
		midpoint = [(r1_coords[0] + r2_coords[0])/2, (r1_coords[1] + r2_coords[1])/2]
		ctx.arrow.strokeStyle = ctx.arrow.fillStyle = regions[id3].color.value()

		# Draw a line from to the midpoint
		ctx.arrow.beginPath()
		ctx.arrow.moveTo r3_coords...
		ctx.arrow.lineTo midpoint...
		ctx.arrow.stroke()

		# Draw a circle at the midpoint. 1.4 is arbitrary here - just something
		# that seemed to look okay.
		ctx.arrow.beginPath()
		ctx.arrow.arc midpoint..., scale/1.4, 0, Math.PI*2, true
		ctx.arrow.fill()

	clearCanvas = (ctx) ->
		ctx.clearRect 0, 0, ctx.canvas.width, ctx.canvas.height

	self.select = (id) ->
		region = regions[id]
		active.push id
		self.refresh()

		return self

	self.emitSelect = (e) ->
		{id, region} = self.evtRegion e
		emitter.trigger 'select', Object.assign({}, region), null

	self.active = -> active

	relCoords = (evt_handler) ->
		(e) ->
			offset = $(this).offset()
			e.pageX = e.pageX - offset.left
			e.pageY = e.pageY - offset.top
			evt_handler e

	# We register all of our events with all of the canvases in the sandwhich -
	# that way it doesn't matter which one is on top.
	onn = (evt, handler) ->
		for name, ctxx of ctx
			$(ctxx.canvas).on evt, relCoords handler

	onn 'click', self.emitSelect

	self

module.exports = Map
