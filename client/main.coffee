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
View           = require './View'

# Templates
CreateGame     = require './CreateGame'
Games          = require './Games'
Game           = require './Game'

$(document).ready () ->
	$container = $ '.container'
	# upload_variant = UploadVariant cnt, gam, map, rgn
	router = Router()
	view = View $container

	router.get '/create', ->
		view.display CreateGame()

	router.get '/games', ->
		view.display Games
			title: "This is a Test Game"
			variant: "LOTR"
			img: "/variants/midearth.bmp"
			countries: ['foo', 'bar', 'baz']

	router.get '/game', ->
		view.display Game img: '/variants/middle-earth/midearth.bmp'

	router.get '/upload-variant', ->
		UploadVariant(view).display()

	router.route()
