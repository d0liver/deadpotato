$              = require 'jquery'

# Virtual DOM
createElement  = require 'virtual-dom/create-element'
diff           = require 'virtual-dom/diff'
patch          = require 'virtual-dom/patch'

# Our stuff
Icons                   = require './Icons'
Map                     = require './Map'
Router                  = require './Router'
UploadVariantController = require './UploadVariantController'
View                    = require './View'

# Templates
CreateGameController = require './CreateGameController'
GameListController   = require './GameListController'
WarRoomController    = require './WarRoomController'
mapWidgetSetup       = require './mapWidgetSetup'

$(document).ready () ->

	$container = $ '.content'
	# upload_variant = UploadVariantController cnt, gam, map, rgn
	router = Router()
	view = View $container

	router.get '/new-game', ->
		CreateGameController $container

	router.get '/games', ->
		GameListController $container

	router.get '/game/:_id', ({_id}) ->
		mapWidgetSetup()
		WarRoomController _id, $container

	router.get '/upload-variant', ->
		UploadVariantController $container

	router.get '/map-test', ->
		mapWidgetSetup()
		gdata = require './map_test_gdata.js'
		vdata = require './map_test_vdata.js'
		vdata.map_data = JSON.parse vdata.map_data

		$('<div>').appendTo('.content').gameMap {gdata, vdata}

	router.route()
