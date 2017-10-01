window.jQuery = $ = require 'jquery'
require 'jquery-ui'

{Gavel, Board, PathFinder} = require 'gavel.js'
Map                        = require './Map'
MapController              = require './controllers/MapController'
MapIcon                    = require '../lib/MapIcon'

S3_BUCKET = "https://s3.us-east-2.amazonaws.com/deadpotato/"

module.exports = ->

	$.widget 'deadpotato.gameMap',
		_create: ->
			if not @options.gdata? or not @options.vdata?
				throw new Error '
				Game and variant data must be defined for the map widget.
			'
			vdata = @options.vdata; gdata = @options.gdata

			header = $ '<h1>'
			header.html gdata.phase.season_year
			@element.append header
			@element.addClass 'root'

			wrapper = $ '<div>'
			wrapper.css position: 'relative'
			@element.append wrapper

			map   = document.createElement 'canvas'
			arrow = document.createElement 'canvas'
			icon  = document.createElement 'canvas'

			ctx =
				map   : map.getContext '2d'
				arrow : arrow.getContext '2d'
				icon  : icon.getContext '2d'

			map_img     = new Image()
			map_img.src = "#{S3_BUCKET}#{vdata.slug}/map.bmp"
			$map_img    = $ map_img

			wrapper.append map_img

			$map_img.on 'load', =>
				width = $map_img.innerWidth(); height = $map_img.innerHeight()

				wrapper.css {width}
				@element.css width: width

				# THIS MUST EXIST. The browser is not smart enough to use the CSS width
				# and height for the canvas (it will scale it like an image rather than
				# actually setting the canvas dimensions). So, if you want to size it
				# with css (which seems reasonable) then you must dig up the CSS
				# properties and manually set them on the canvas.
				for c in Object.values ctx
					$(c.canvas).css {width, height}
					c.canvas.width = width; c.canvas.height = height
					wrapper.append c.canvas

				# New Map constructor that only takes the regions - needed for map
				# creation in the controller (it's better to have the business logic
				# for the regions there).
				board = Board gdata, vdata
				pfinder = new PathFinder board
				gavel = new Gavel board, pfinder, gdata.phase.season_year
				map = Map ctx, MapIcon.bind null, vdata.slug, vdata.assets
				@_map_controller = new MapController gavel, board, pfinder, map, gdata, vdata

		orders: ->
			@_map_controller.orders()

		# _setOption: (key, value)
		# 	if key is 'value'
		# 		value = @_constrain value
		# 	@_super key, value

		# _setOptions: (options) ->
		# 	@_super options
		# 	@refresh()

		# _destroy: ->
		# 	@element.removeClass 'root'
