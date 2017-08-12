h             = require 'virtual-dom/h'
co            = require 'co'
gqlQuery      = require './gqlQuery'
$             = require 'jquery'
VariantImages = require './VariantImages'

Games = (view) ->
	self = {}
	authed = false

	init = co.wrap ->
		{data: {listGames: games}} = yield gqlQuery """
			{
				listGames {
					_id
					title
					players {
						country
					}
					variant {
						slug
						countries {
							name
						}
					}
				}
			}
		"""
		console.log "FETCHED GAMES: ", games
		{data: {isAuthed: authed}} = yield gqlQuery "
			{
				isAuthed
			}
		"
		self.display games

	joinGame = ->
		$this = $(this)
		country = $this.siblings('#select-country').val()
		_id = $this.siblings('#_id').val()
		gqlQuery """
			mutation joinGame($country: String!, $game: ObjectID!) {
				joinGame(country: $country, game: $game)
			}
		""", {game: _id, country}
		# window.location.replace "/game/#{_id}"

	self.display = (games) ->
		console.log "Attempting to display games: ", games
		view.display h '.root', [
			h 'ul.games-list',
				for game in games
					console.log "Game: ", game
					h 'li', [
						h 'h2.games-list-title', game.title
						h 'img.map', src: VariantImages(game.variant.slug).map()
						h 'p', [
							h 'strong.countries-list-title', 'Countries'
							do ->
								str = ""
								for {name} in game.variant.countries
									comma = ("," if str isnt '') ? ''
									str = "#{str}#{comma} #{name}"

								return str
						]
						h 'strong.countries-list-title', style: 'margin-top: 20px', 'Select Country'
						h 'select', id: 'select-country', do ->
							game.variant.players ?= []
							player_countries = (player.country for player in game.variant.players)
							for {name} in game.variant.countries when \
							name not in player_countries
								h 'option', name
						h 'input#_id', type: 'hidden', value: game._id
						h 'a.join-game', id: 'join-game', onclick: joinGame, do ->
							if authed then 'Join Game' else ''
					]
		]

	init()
	return self

module.exports = Games
