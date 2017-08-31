co       = require 'co'
$        = require 'jquery'

gqlQuery                    = require './gqlQuery'
{CREATE_GAME_Q, VARIANTS_Q} = require './gqlQueries'

template = require '../views/create-game.pug'

CreateGameController = ($el)->
	self = {}

	init = ->
		co ->
			{variants} = yield gqlQuery VARIANTS_Q
			$el.html template {variants}
			console.log "Variants: ", variants

			$el.find('.create-game').on 'submit', (e) ->
				e.preventDefault()
				title = $('#title').val(); variant = $('#which-variant').val()
				{game: {create: _id}} = yield gqlQuery CREATE_GAME_Q, {title, variant}
				window.location.replace "/game/#{_id}"

	init()
	return self

module.exports = CreateGameController
