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
GameController     = require './GameController'

$(document).ready () ->
	$container = $ '.container'
	# upload_variant = UploadVariant cnt, gam, map, rgn
	router = Router()
	view = View $container

	router.get '/new-game', ->
		CreateGame view

	router.get '/games', ->
		GameListController view

	router.get '/game/:_id', ({_id}) ->
		GameController _id, view

	router.get '/upload-variant', ->
		UploadVariant(view).display()

	router.route()
