$                        = require 'jquery'
VariantUtils             = require '../lib/VariantUtils'
Color                    = require '../lib/Color'
co                       = require 'co'
AreaTexture              = require './AreaTexture'
HorizLinesTextureBuilder = require './HorizLinesTextureBuilder'
Emitter                  = require '../lib/Emitter'

Map = (ctx, MapIcon) ->
	self = {}
	# Used to scale up and down arrows and binds
	scale = 4
	emitter = Emitter()
	active = []
	areas = {}
	# Map the normal area color to the one that we will use for a particular
	# state
	state_colors =
		normal: (color) -> color
		active: (color) -> color.copy().darken 30

	self.on = emitter.on

	self.addArea = (id, area) ->
		if area.color then area.color = Color area.color
		area.texture = {}
		# We also save the id on the area to make working with them
		# internally easier (we can pass around areas by reference here but
		# don't have to do a lookup when getting the id for external
		# interactions)
		area.id = id
		areas[id] = area

	self.clearActive = ->
		active = []
		self.refresh()

	self.clearArrows = -> clearCanvas ctx.arrow

	# Get the area that the event is over or null if it's not over an area.
	self.evtArea = (e) ->
		[x, y] = [e.pageX, e.pageY]

		for id, area of areas
			for scanline in area.scanlines
				{x: sx, y: sy, len: slen} = scanline
				if y is sy and sx < x < sx + slen
					return {id, area}
		return

	self.display = -> self.refresh false

	# Redraw everything on the map. Note that if clear is false then we can
	# skip the initial canvas clear (i.e. display instead of refresh).
	self.refresh = (clear = true)->
		clearCanvas ctx.map if clear
		for id,area of areas
			# Draw the fill first
			state =
				if area.id in active then 'active'
				else 'normal'
			self.showArea area, state: state, refresh: false

		return self

	self.showArea = (area, {state = 'normal', refresh = true}) ->
		if area.fill or area.id in active
			unless area.texture[state]?
				{scanlines, color = Color 'black'} = area
				tb = if state is 'normal'
					HorizLinesTextureBuilder color: state_colors[state] color
				else if state is 'active'
					# Fill completely for the active selection
					HorizLinesTextureBuilder color: state_colors[state](color), byy: 1

				area.texture[state] = AreaTexture scanlines, tb

			area.texture[state].draw ctx.map
		self.showIcon area if area.icon?

	self.showIcon = (area) ->
		img = await MapIcon(area.color, area.icon).img()
		[x, y] = area.unit_pos
		# The given positions are for the center of the image so we have to
		# subtract half since our coords are for top left
		ctx.icon.drawImage img, x - 16, y - 16, 32, 32

		return self

	self.setIcon = (rid, icon) ->
		area = areas[rid]
		area.icon = icon
		area.fill = false
		area.color = Color 'black'
		self.refresh()

	# Draw an arrow from one area1 to area2
	self.arrow = (id1, id2) ->
		triangle_side = 10
		r1_coords = areas[id1].unit_pos
		r2_coords = areas[id2].unit_pos
		ctx.arrow.strokeStyle = ctx.arrow.fillStyle = areas[id1].color.css('hex')

		# First draw the line connecting the areas
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

	self.convoy = (id1, id2) ->
		r1_coords = areas[id1].unit_pos
		r2_coords = areas[id2].unit_pos
		color = areas[id2].color.css() ? '#000000'
		# Dimensions in pixels. TODO: Relate this to the scale
		width = scale*3
		radius =0.8*width/2

		imgctx = document.createElement('canvas').getContext '2d'
		imgctx.canvas.width = width; imgctx.canvas.height = width
		imgctx.globalAlpha = 0.87
		# Border circle
		imgctx.strokeStyle = color
		imgctx.fillStyle = '#ffffff'
		imgctx.lineWidth = .2*width
		imgctx.beginPath()
		imgctx.arc width/2, width/2, radius, 0, 2* Math.PI
		imgctx.closePath()
		# Border for the circle
		imgctx.stroke()

		# Fill for the circle
		imgctx.fill()

		# Draw the 'c' in the center
		font_size = radius*2*0.9
		# TODO: Relate this to the scale
		imgctx.fillStyle = color
		imgctx.textBaseline = 'middle'
		imgctx.font = "bold #{font_size}px serif"

		text = imgctx.measureText 'C'
		imgctx.fillText 'C', (width - text.width)/2, width/2
		ctx.icon.drawImage(
			imgctx.canvas
			(r1_coords[0] + r2_coords[0] - width)/2
			(r1_coords[1] + r2_coords[1] - width)/2
		)
		ctx.arrow.strokeStyle = color
		ctx.arrow.beginPath()
		ctx.arrow.moveTo r1_coords[0], r1_coords[1]
		ctx.arrow.lineTo r2_coords[0], r2_coords[1]
		ctx.arrow.stroke()

	# Draw a line from a unit to intersect with the line of another arrow. Used
	# to indicate support
	self.bind = (id1, id2, id3) ->
		r1_coords = areas[id1].unit_pos
		r2_coords = areas[id2].unit_pos
		r3_coords = areas[id3].unit_pos
		midpoint = [(r1_coords[0] + r2_coords[0])/2, (r1_coords[1] + r2_coords[1])/2]
		ctx.arrow.strokeStyle = ctx.arrow.fillStyle = areas[id3].color.css('hex')

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
		area = areas[id]
		active.push id
		self.refresh()

		return self

	self.emitSelect = (e) ->
		{id, area} = self.evtArea e
		emitter.trigger 'select', area, null

	Object.defineProperty self, 'active', get: -> active

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
