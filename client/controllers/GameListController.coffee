_             = require 'underscore'
co            = require 'co'
gqlQuery      = require '../gqlQuery'
$             = require 'jquery'
VariantImages = require '../VariantImages'

{S3_BUCKET} = require '../../lib/config'
template      = require '../../views/games-list.pug'

{GAMES_Q, IS_AUTHED_Q, JOIN_GAME_Q} = require '../gqlQueries'

class GamesListController
	constructor: (@_$el) ->
		@_init()

	# Not in the constructor because the constructor cannot be async
	_init: ->

		{games} = await gqlQuery GAMES_Q
		console.log "Games: ", games
		players = []
		# We go through and attach the available countries to each game.
		# This feels somewhat hacky - like maybe it should be in the view
		# but this is much easier.
		for game in games
			pcountries = (player.country for player in players)
			gcountries = (country.name for country in game.phase.countries)
			game.available_countries = _.difference gcountries, pcountries
			game.phase.countries = gcountries
			game.map_src = "#{S3_BUCKET}#{game.variant.slug}/map.bmp"

		@_$el.html template {games}

	_join: ->
		$this = $(this)
		country = $this.siblings('#select-country').val()
		_id = $this.siblings('#_id').val()

		await gqlQuery JOIN_GAME_Q, {game: _id, country}

		# window.location.replace "/game/#{_id}"

module.exports = GamesListController
