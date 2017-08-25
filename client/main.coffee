$              = require 'jquery'

# Virtual DOM
createElement  = require 'virtual-dom/create-element'
diff           = require 'virtual-dom/diff'
patch          = require 'virtual-dom/patch'

# Our stuff
Icons         = require './Icons'
Map           = require './Map'
Router        = require './Router'
UploadVariant = require './UploadVariant'
View          = require './View'

# Templates
CreateGame         = require './CreateGame'
GameListController = require './GameListController'
WarRoomController  = require './WarRoomController'
mapWidgetSetup     = require './mapWidgetSetup'

$(document).ready () ->

	$container = $ '.content'
	# upload_variant = UploadVariant cnt, gam, map, rgn
	router = Router()
	view = View $container

	router.get '/new-game', ->
		CreateGame view

	router.get '/games', ->
		GameListController view

	router.get '/game/:_id', ({_id}) ->
		mapWidgetSetup()
		WarRoomController _id, view

	router.get '/upload-variant', ->
		UploadVariant(view).display()

	router.get '/map-test', ->
		mapWidgetSetup()
		gdata = require './map_test_gdata.js'
		vdata = require './map_test_vdata.js'
		vdata.map_data = JSON.parse vdata.map_data

		$('<div>').appendTo('.content').gameMap {gdata, vdata}

	router.route()
