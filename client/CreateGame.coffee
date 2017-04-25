h        = require 'virtual-dom/h'
gqlQuery = require './gqlQuery'
co       = require 'co'
$        = require 'jquery'

CreateGame = (view)->
	self = {}

	init = ->
		co ->
			{data: {variants}} = yield gqlQuery """
				{
					variants {
						_id
						name
					}
				}
			"""
			self.display variants

			$('.create-game').on 'submit', (e) ->
				e.preventDefault()
				title = $('#title').val(); variant = $('#which-variant').val()
				console.log "Title: ", title, "variant: ", variant
				createGame {title, variant}

	createGame = co.wrap (game) ->
		console.log "Saving game:", {game}
		{data: createGame: _id} = yield gqlQuery """
			mutation createGame($game: GameArg) {
				createGame(game: $game)
			}
		""", {game}
		window.location.replace "/game/#{_id}"


	self.display = (variants) ->
		view.display h 'form.create-game', [
			h '.row', [
				h '.six.columns', [
					h 'label', htmlFor: 'title', 'Game Title'
					h 'input#title.u-full-width', type: 'text', name: 'title'
				]
				h '.five.columns', [
					h 'label', htmlFor: 'which-variant', 'Variant'
					h 'select#which-variant.u-full-width', {},
						for {name, _id} in variants
							h 'option', value: _id, name
				]
				h '.one.columns', h 'label'  
			]
			h 'input.button-primary', type: 'submit', value: 'Start'
		]

	init()
	return self

module.exports = CreateGame
