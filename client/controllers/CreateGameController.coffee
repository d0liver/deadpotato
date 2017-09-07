$        = require 'jquery'

gqlQuery                    = require '../gqlQuery'
{CREATE_GAME_Q, VARIANTS_Q} = require '../gqlQueries'

template = require '../../views/create-game.pug'

class CreateGameController
	constructor: (@$el) -> @render()

	render: ->
		{variants} = await gqlQuery VARIANTS_Q
		console.log "Variants: ", variants
		@$el.html template {variants}

		@$el.find('.create-game').on 'submit', (e) ->
			e.preventDefault()
			title = $('#title').val(); variant = $('#which-variant').val()
			{game: {create: _id}} = await gqlQuery CREATE_GAME_Q, game: {title, variant}
			window.location.replace "/game/#{_id}"

module.exports = CreateGameController
