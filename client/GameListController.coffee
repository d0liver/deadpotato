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
					countries {
						name
					}
					variant {
						slug
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

	init()
	return self

module.exports = Games
