$              = require 'jquery'

# Virtual DOM
createElement  = require 'virtual-dom/create-element'
diff           = require 'virtual-dom/diff'
patch          = require 'virtual-dom/patch'

# Our stuff
GameInfo       = require './GameInfo'
Icons          = require './Icons'
Map            = require './Map'
RegionTexture  = require './RegionTexture'
RouteHandler   = require './RouteHandler'
Router         = require './Router'
TextureBuilder = require './TextureBuilder'
UploadVariant  = require './UploadVariant'

# Templates
CreateGame     = require './CreateGame'
Games          = require './Games'
Game           = require './Game'

$(document).ready () ->
	$container = $ '.container'
	# upload_variant = UploadVariant cnt, gam, map, rgn
	router = Router()

	router.get '/create', ->
		tree = CreateGame()
		root = createElement tree
		$container.append root

	router.get '/games', ->
		tree = Games
			title: "This is a Test Game"
			variant: "LOTR"
			img: "/variants/midearth.bmp"
			countries: ['foo', 'bar', 'baz']

		root = createElement tree
		console.log "ROOT: ", root
		$container.append root

	router.get '/game', ->
		tree = Game img: '/variants/middle-earth/midearth.bmp'
		root = createElement tree
		$container.append root

	router.get '/upload-variant', ->
		tree = UploadVariant().tree()
		root = createElement tree
		$container.append root

	router.route()
