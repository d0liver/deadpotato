$              = require 'jquery'

{Gavel} = require 'gavel.js'

# Our stuff
Icons                   = require './Icons'
Map                     = require './Map'
Router                  = require './Router'
UploadVariantController = require './controllers/UploadVariantController'

# Templates
CreateGameController = require './controllers/CreateGameController'
GameListController   = require './controllers/GameListController'
WarRoomController    = require './controllers/WarRoomController'
NavMenuController    = require './controllers/NavMenuController'
mapWidgetSetup       = require './mapWidgetSetup'

gqlQuery = require './gqlQuery'
{GAME_Q} = require './gqlQueries'

$(document).ready () ->

	$container = $ '.content'

	# upload_variant = UploadVariantController cnt, gam, map, rgn
	router = Router()

	new NavMenuController

	router.get '/new-game', ->
		new CreateGameController $container

	router.get '/games', ->
		new GameListController $container

	router.get '/game/:_id', ({_id}) ->
		console.log "ID: ", _id
		{games: [gdata]} = await gqlQuery GAME_Q, {_id}
		console.log "GDATA: ", gdata
		vdata = gdata.variant
		vdata.map_data = JSON.parse vdata.map_data
		gavel = new Gavel gdata, vdata
		# XXX: For testing
		console.log "Bagels"
		gavel.country = 'Germany'
		mapWidgetSetup gavel
		wrc = new WarRoomController _id, $container
		wrc.init()

	router.get '/upload-variant', ->
		UploadVariantController $container

	router.get '/map-test', ->
		mapWidgetSetup()
		gdata = require './map_test_gdata.js'
		vdata = require './map_test_vdata.js'
		vdata.map_data = JSON.parse vdata.map_data

		$('<div>').appendTo('.content').gameMap {gdata, vdata}

	router.route()
