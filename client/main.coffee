$              = require 'jquery'
ColorMap       = require './ColorMap'
GameInfo       = require './GameInfo'
Icons          = require './Icons'
Map            = require './Map'
RegionTexture  = require './RegionTexture'
RouteHandler   = require './RouteHandler'
Router         = require './Router'
TextureBuilder = require './TextureBuilder'
UploadVariant  = require './UploadVariant'

# Virtual DOM
createElement  = require 'virtual-dom/create-element'
diff           = require 'virtual-dom/diff'
patch          = require 'virtual-dom/patch'

cnt            = require "./cnt"
gam            = require "./gam"
map            = require "./map"
rgn            = require "./rgn"

# Templates
CreateGame     = require './CreateGame'
Games          = require './Games'
board_template = require '../views/board.jade'

$(document).ready () ->
	$container = $ '.container'
	upload_variant = UploadVariant cnt, gam, map, rgn
	router = Router()

	router.get '/create': ->
		tree = CreateGame()
		root = createElement tree
		$container.append root

	router.get '/games': ->
		tree = Games
			title: "This is a Test Game"
			variant: "LOTR"
			img: "midearth.bmp"
			countries: ['foo', 'bar', 'baz']

		root = createElement tree
		console.log "ROOT: ", root
		$container.append root

	router.route()
